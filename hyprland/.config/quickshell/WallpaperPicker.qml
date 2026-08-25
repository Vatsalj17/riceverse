import QtQuick
import QtQuick.Layouts
import QtCore
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Item {
    id: window

    MatugenColors {
        id: _theme
    }

    // -------------------------------------------------------------------------
    // PROPERTIES & IPC RECEIVER
    // -------------------------------------------------------------------------
    property string widgetArg: ""
    property string targetWallName: ""
    property bool initialFocusSet: false
    property int visibleItemCount: -1
    property int scrollAccum: 0
    property int scrollThreshold: 300

    // Filter System Properties
    property string currentFilter: "All"
    property string _lastFilter: "All"
    property string searchQuery: ""
    property bool isOnlineSearch: false
    property bool isSearchPaused: false
    property bool hasSearched: false
    property int cacheVersion: 0

    // Download and Status Tracking Properties
    property bool isDownloadingWallpaper: false
    property string currentDownloadName: ""

    // Reactive Status Properties
    property bool isStartup: localFolderModel.status === FolderListModel.Loading || srcModel.status === FolderListModel.Loading
    property bool isReady: visible && localFolderModel.status === FolderListModel.Ready
    property bool isSearchActive: window.currentFilter === "Search" && window.hasSearched && searchFolderModel.status === FolderListModel.Loading

    // Memory Properties for Search
    property string lastSearchName: ""
    property bool isModelChanging: false
    property bool searchIndexRestored: false

    // Lock scrolling/interaction while actively streaming search results.
    property bool isScrollingBlocked: window.currentFilter === "Search" && window.hasSearched && window.isSearchActive && !window.isSearchPaused
    property bool jumpToLastOnFilterChange: false

    // Only All, Video, Search — color filters removed
    readonly property var filterData: [
        {
            name: "All",
            hex: "",
            label: "All"
        },
        {
            name: "Video",
            hex: "",
            label: "Vid"
        },
        {
            name: "Search",
            hex: "",
            label: "Search"
        }
    ]

    // -------------------------------------------------------------------------
    // GLOBAL ACTION: APPLY WALLPAPER
    // -------------------------------------------------------------------------
    function applyWallpaper(safeFileName, isVideo) {
        if (!safeFileName)
            return;

        window.targetWallName = safeFileName;
        let cleanName = window.getCleanName(safeFileName);
        let reloadScript = Qt.resolvedUrl("matugen_reload.sh").toString();

        if (reloadScript.startsWith("file://")) {
            reloadScript = decodeURIComponent(reloadScript.substring(7));
        }

        const escapeBash = str => String(str).replace(/(["\\$`])/g, '\\$1');

        if (window.currentFilter === "Search" && window.hasSearched) {
            let destFile = window.appliedDir + "/" + safeFileName;
            let tempThumb = decodeURIComponent(window.searchDir.replace("file://", "")) + "/" + safeFileName;
            let mapFile = Quickshell.env("HOME") + "/.cache/wallpaper_picker/search_map.txt";
            const randomTransition = window.transitions[Math.floor(Math.random() * window.transitions.length)];

            window.isDownloadingWallpaper = true;
            window.currentDownloadName = safeFileName;

            const downloadScript = `
            export SAFE_NAME="${escapeBash(safeFileName)}"
            export DEST_FILE="${escapeBash(destFile)}"
            export TEMP_THUMB="${escapeBash(tempThumb)}"
            export RELOAD_SCRIPT="${escapeBash(reloadScript)}"
            export MAP_FILE="${escapeBash(mapFile)}"

            (
                if [ ! -f "$DEST_FILE" ]; then
                URL=$(awk -F'|' -v fname="$SAFE_NAME" '$1 == fname {print $2; exit}' "$MAP_FILE")
                if [ -n "$URL" ]; then
                curl -s -L -A "Mozilla/5.0" "$URL" -o "$DEST_FILE.tmp"
                if file "$DEST_FILE.tmp" | grep -iq "webp"; then
                magick "$DEST_FILE.tmp" "$DEST_FILE"
                rm -f "$DEST_FILE.tmp"
                else
                mv "$DEST_FILE.tmp" "$DEST_FILE"
                fi
                fi
                fi

                if [ -f "$DEST_FILE" ]; then
                cp "$DEST_FILE" /tmp/lock_bg.png
                pkill mpvpaper || true
                awww img "$DEST_FILE" --transition-type ${randomTransition} --transition-pos 0.5,0.5 --transition-fps 144 --transition-duration 1 &
                matugen image "$TEMP_THUMB" && bash "$RELOAD_SCRIPT"
                wait
                fi
                echo 'done' > /tmp/qs_download_done
            ) >/dev/null 2>&1 & disown
            `;

            Quickshell.execDetached(["bash", "-c", downloadScript]);
            return;
        }

        // Only strip the .jpg if we know for a fact it is a video thumbnail
        let actualFileName = isVideo ? safeFileName.replace(/\.jpg$/i, "") : safeFileName;

        // Dynamically route to the correct folder
        const originalFile = isVideo ? (window.vidDir + "/" + actualFileName) : (window.srcDir + "/" + actualFileName);

        // Keep thumbFile pointing to the cache
        const thumbFile = Quickshell.env("HOME") + "/.cache/wallpaper_picker/thumbs/" + safeFileName;

        // const originalFile = window.srcDir + "/" + cleanName
        // const thumbFile = Quickshell.env("HOME") + "/.cache/wallpaper_picker/thumbs/" + safeFileName

        let wallpaperCmd = "";
        let lockBgCmd = "";

        const escOriginal = escapeBash(originalFile);
        const escThumb = escapeBash(thumbFile);
        const escReload = escapeBash(reloadScript);

        if (isVideo) {
            wallpaperCmd = `mpvpaper -o 'loop --no-audio --hwdec=auto --profile=high-quality --video-sync=display-resample --interpolation --tscale=oversample' '*' "$WALL_FILE"`;
            lockBgCmd = `cp "$THUMB_FILE" /tmp/lock_bg.png`;
        } else {
            const randomTransition = window.transitions[Math.floor(Math.random() * window.transitions.length)];
            wallpaperCmd = `awww img "$WALL_FILE" --transition-type ${randomTransition} --transition-pos 0.5,0.5 --transition-fps 144 --transition-duration 1`;
            lockBgCmd = `cp "$WALL_FILE" /tmp/lock_bg.png`;
        }

        const fullScript = `
            export WALL_FILE="${escOriginal}"
            export THUMB_FILE="${escThumb}"
            export RELOAD_SCRIPT="${escReload}"

            (
                ${lockBgCmd}
                pkill mpvpaper || true
                ${wallpaperCmd} &
                matugen image "$THUMB_FILE" && bash "$RELOAD_SCRIPT"
                wait
            ) >/dev/null 2>&1 & disown
        `;

        Quickshell.execDetached(["bash", "-c", fullScript]);
        Quickshell.execDetached(["bash", "-c", "echo 'close' > /tmp/qs_widget_state"]);
    }

    // -------------------------------------------------------------------------
    // PERSISTENT SETTINGS
    // -------------------------------------------------------------------------
    Settings {
        id: searchState
        category: "QS_WallpaperPicker"
        property string query: ""
        property bool searched: false
        property string lastName: ""
    }

    onIsSearchPausedChanged: {
        Quickshell.execDetached(["bash", "-c", "echo '" + (isSearchPaused ? "pause" : "run") + "' > /tmp/ddg_search_control"]);
    }

    // -------------------------------------------------------------------------
    // VISIBILITY LOGIC
    // -------------------------------------------------------------------------
    onVisibleChanged: {
        if (!visible) {
            window.initialFocusSet = false;
            window.searchIndexRestored = false;

            if (window.hasSearched) {
                window.isSearchPaused = true;
            }
        } else {
            if (window.currentFilter !== "Search") {
                window.applyFilters(true);
            } else if (window.hasSearched) {
                window.searchIndexRestored = false;
                window.isSearchPaused = true;
                window.trySearchFocus();
                window.syncSearchModel();
            }
        }
    }

    // -------------------------------------------------------------------------
    // NOTIFICATION & LABEL STATE LOGIC
    // -------------------------------------------------------------------------
    property bool isLoading: localFolderModel.status === FolderListModel.Loading || srcModel.status === FolderListModel.Loading || (window.currentFilter === "Search" && searchFolderModel.status === FolderListModel.Loading)

    property bool showSpinner: window.isDownloadingWallpaper || (window.currentFilter === "Search" && window.hasSearched && !window.isSearchPaused) || (window.currentFilter !== "Search" && window.isLoading)

    property string currentNotification: {
        if (window.isDownloadingWallpaper)
            return "Downloading wallpaper...";

        if (window.currentFilter === "Search") {
            if (!window.hasSearched)
                return "Type something to search...";
            if (window.isSearchPaused)
                return "Search Paused";
            if (window.visibleItemCount === 0)
                return "Searching DDG (FHD+)...";
            return "Generating thumbnails...";
        }

        if (isLoading)
            return "Generating thumbnails...";
        if (window.visibleItemCount === 0)
            return "No wallpapers found";

        if (window.currentFilter === "All")
            return "";
        if (window.currentFilter === "Video")
            return "Videos";

        return window.currentFilter;
    }

    property bool showNotification: !window.isStartup && currentNotification !== ""

    function getCleanName(name) {
        if (!name)
            return "";
        let clean = String(name);
        return clean.startsWith("000_") ? clean.substring(4) : clean;
    }

    // function isDownloaded(name) {
    //     if (!name) return false;
    //     // check applied dir, not srcModel
    //     let path = window.appliedDir + "/" + name;
    //     return Quickshell.env("HOME") !== "" && Qt.resolvedUrl("file://" + path).toString() !== "";
    // }

    // function isDownloaded(name) {
    //     if (!name) return false;
    //     for (let i = 0; i < appliedModel.count; i++) {
    //         if (appliedModel.get(i, "fileName") === name) return true;
    //     }
    //     return false;
    // }

    // function isDownloaded(name) {
    //     if (!name) return false;
    //     for (let i = 0; i < srcModel.count; i++) {
    //         if (srcModel.get(i, "fileName") === name) return true;
    //     }
    //     return false;
    // }

    onWidgetArgChanged: {
        if (widgetArg !== "") {
            targetWallName = widgetArg;
            initialFocusSet = false;
            tryFocus();
        }
    }

    function executeFocusRestore(targetIndex, isSearchRestore, requirePositioning) {
        let targetModel = window.getModelForFilter(window.currentFilter);

        if (targetIndex !== -1 && targetIndex < targetModel.count) {
            window.isModelChanging = true;

            if (requirePositioning) {
                view.forceLayout();
                view.positionViewAtIndex(targetIndex, ListView.Center);
            }

            view.currentIndex = targetIndex;

            if (isSearchRestore) {
                window.searchIndexRestored = true;
            }

            window.isModelChanging = false;
            window.initialFocusSet = true;
        } else if (isSearchRestore) {
            window.searchIndexRestored = true;
        }
    }

    function tryFocus() {
        if (initialFocusSet)
            return;

        if (localProxyModel.count > 0) {
            let foundIndex = -1;
            let cleanTarget = window.getCleanName(targetWallName);

            if (cleanTarget !== "") {
                for (let i = 0; i < localProxyModel.count; i++) {
                    let fname = localProxyModel.get(i).fileName || "";
                    if (window.getCleanName(fname) === cleanTarget) {
                        foundIndex = i;
                        break;
                    }
                }
            }

            let finalIndex = foundIndex !== -1 ? foundIndex : 0;
            window.executeFocusRestore(finalIndex, false, true);
        }
    }

    function trySearchFocus() {
        if (window.searchIndexRestored || searchProxyModel.count === 0)
            return;

        if (window.lastSearchName === "") {
            window.searchIndexRestored = true;
            return;
        }

        for (let i = 0; i < searchProxyModel.count; i++) {
            let fname = searchProxyModel.get(i).fileName || "";
            if (fname === window.lastSearchName) {
                window.executeFocusRestore(i, true, true);
                return;
            }
        }

        if (searchFolderModel.status === FolderListModel.Ready && searchProxyModel.count === searchFolderModel.count) {
            window.searchIndexRestored = true;
        }
    }

    function getModelForFilter(filter) {
        return filter === "Search" ? searchProxyModel : localProxyModel;
    }

    function updateVisibleCount() {
        let targetModel = window.getModelForFilter(window.currentFilter);

        if (!targetModel || targetModel.count === 0) {
            window.visibleItemCount = 0;
            return;
        }
        let count = 0;
        for (let i = 0; i < targetModel.count; i++) {
            let fname = targetModel.get(i).fileName || "";
            // let isVid = fname.startsWith("000_");
            let isVid = fname.match(/\.(mp4|mkv|webm|mov)\.jpg$/i) !== null;
            if (checkItemMatchesFilter(fname, isVid, window.cacheVersion, window.currentFilter)) {
                count++;
            }
        }
        window.visibleItemCount = count;
    }

    function triggerOnlineSearch() {
        if (searchInput.text.trim() === "")
            return;

        window.isModelChanging = true;
        searchProxyModel.clear();
        window.lastSearchName = "";
        searchState.lastName = "";

        if (window.currentFilter === "Search") {
            view.currentIndex = 0;
            view.positionViewAtIndex(0, ListView.Center);
        }
        window.isModelChanging = false;

        window.searchIndexRestored = true;
        window.isOnlineSearch = true;
        window.hasSearched = true;

        window.visibleItemCount = 0;

        searchState.searched = true;
        searchState.query = searchInput.text.trim();

        window.isSearchPaused = false;
        window.searchQuery = searchInput.text.trim();

        let rawSearchDir = decodeURIComponent(window.searchDir.replace(/^file:\/\//, ""));
        let scriptPath = decodeURIComponent(Qt.resolvedUrl("ddg_search.sh").toString().replace(/^file:\/\//, ""));

        const cmd = `
            exec > /tmp/qs_ddg_run.log 2>&1
            echo "=== QML Shell Handoff Successful ==="
            export PATH=$PATH:/run/current-system/sw/bin

            echo "Gracefully stopping old processes..."
            echo 'stop' > /tmp/ddg_search_control

            for p in $(pgrep -f ddg_search.sh); do
                if [ "$p" != "$$" ] && [ "$p" != "$BASHPID" ]; then
                    kill -9 $p 2>/dev/null || true
                fi
            done
            pkill -f "[g]et_ddg_links.py" || true
            sleep 0.2

            echo "Clearing old cache..."
            rm -rf "${rawSearchDir}"/* || true
            rm -f "${rawSearchDir}/../search_map.txt" || true

            echo "Setting control state back to run..."
            echo 'run' > /tmp/ddg_search_control

            echo "Executing new search pipeline..."
            bash "${scriptPath}" "${window.searchQuery}" &
        `;

        Quickshell.execDetached(["bash", "-c", cmd]);

        searchInput.focus = false;
        view.forceActiveFocus();
    }

    readonly property string homeDir: "file://" + Quickshell.env("HOME")
    readonly property string thumbDir: homeDir + "/.cache/wallpaper_picker/thumbs"
    readonly property string searchDir: homeDir + "/.cache/wallpaper_picker/search_thumbs"
    readonly property string appliedDir: Quickshell.env("HOME") + "/.cache/wallpaper_picker/applied"
    readonly property string srcDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    readonly property string vidDir: Quickshell.env("HOME") + "/Videos/wallpapers" // NEW

    readonly property var transitions: ["grow", "outer", "any", "wipe", "wave", "pixel", "center"]

    readonly property int itemWidth: 400
    readonly property int itemHeight: 420
    readonly property int borderWidth: 3
    readonly property int spacing: 10
    readonly property real skewFactor: -0.35

    Timer {
        id: scrollThrottle
        interval: 150
    }

    // -------------------------------------------------------------------------
    // FILTER LOGIC — no color buckets needed anymore
    // -------------------------------------------------------------------------
    function checkItemMatchesFilter(fileName, isVid, cv, filter) {
        if (filter === "Search")
            return true;
        if (filter === "All")
            return true;
        if (filter === "Video")
            return isVid;
        return true;
    }

    FolderListModel {
        id: srcModel
        folder: "file://" + window.srcDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.mp4", "*.mkv", "*.mov", "*.webm"]
        showDirs: false
    }

    Timer {
        id: downloadTimeout
        interval: 15000
        running: window.isDownloadingWallpaper
        repeat: false
        onTriggered: window.isDownloadingWallpaper = false
    }

    // FolderListModel {
    //     id: srcModel
    //     folder: "file://" + window.srcDir
    //     nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.mp4", "*.mkv", "*.mov", "*.webm"]
    //     showDirs: false
    //     onCountChanged: {}
    //
    //     // onCountChanged: {
    //     //     if (window.isDownloadingWallpaper && window.isDownloaded(window.currentDownloadName)) {
    //     //         window.isDownloadingWallpaper = false;
    //     //     }
    //     // }
    // }

    function stepToNextValidIndex(direction) {
        let targetModel = window.getModelForFilter(window.currentFilter);
        if (!targetModel || targetModel.count === 0)
            return;

        let start = view.currentIndex;
        let found = -1;

        if (direction === 1) {
            for (let i = start + 1; i < targetModel.count; i++) {
                let fname = targetModel.get(i).fileName || "";
                // let isVid = fname.startsWith("000_");
                let isVid = fname.match(/\.(mp4|mkv|webm|mov)\.jpg$/i) !== null;
                if (checkItemMatchesFilter(fname, isVid, window.cacheVersion, window.currentFilter)) {
                    found = i;
                    break;
                }
            }
        } else {
            for (let i = start - 1; i >= 0; i--) {
                let fname = targetModel.get(i).fileName || "";
                // let isVid = fname.startsWith("000_");
                let isVid = fname.match(/\.(mp4|mkv|webm|mov)\.jpg$/i) !== null;
                if (checkItemMatchesFilter(fname, isVid, window.cacheVersion, window.currentFilter)) {
                    found = i;
                    break;
                }
            }
        }

        if (found !== -1) {
            view.currentIndex = found;
            return;
        }

        // Wrap around within the same filter
        let current = start;
        for (let i = 0; i < targetModel.count; i++) {
            current = (current + direction + targetModel.count) % targetModel.count;
            let fname = targetModel.get(current).fileName || "";
            // let isVid = fname.startsWith("000_");
            let isVid = fname.match(/\.(mp4|mkv|webm|mov)\.jpg$/i) !== null;
            if (checkItemMatchesFilter(fname, isVid, window.cacheVersion, window.currentFilter)) {
                view.currentIndex = current;
                return;
            }
        }
    }

    function cycleFilter(direction) {
        let currentIdx = -1;
        for (let i = 0; i < window.filterData.length; i++) {
            if (window.filterData[i].name === window.currentFilter) {
                currentIdx = i;
                break;
            }
        }

        if (currentIdx !== -1) {
            let nextIdx = (currentIdx + direction + window.filterData.length) % window.filterData.length;
            window.currentFilter = window.filterData[nextIdx].name;
        }
    }

    function applyFilters(forceSnap) {
        let targetModel = window.getModelForFilter(window.currentFilter);

        if (!targetModel || targetModel.count === 0) {
            window.updateVisibleCount();
            return;
        }

        if (window.currentFilter === "Search") {
            window.updateVisibleCount();
            return;
        }

        let firstValidIndex = -1;
        let lastValidIndex = -1;
        let cleanTarget = window.getCleanName(window.targetWallName);
        let targetIndex = -1;

        for (let i = 0; i < targetModel.count; i++) {
            let fname = targetModel.get(i).fileName || "";
            // let isVid = fname.startsWith("000_");
            let isVid = fname.match(/\.(mp4|mkv|webm|mov)\.jpg$/i) !== null;

            if (checkItemMatchesFilter(fname, isVid, window.cacheVersion, window.currentFilter)) {
                if (firstValidIndex === -1)
                    firstValidIndex = i;
                lastValidIndex = i;
                if (cleanTarget !== "" && window.getCleanName(fname) === cleanTarget)
                    targetIndex = i;
            }
        }

        let indexToFocus = -1;

        if (targetIndex !== -1) {
            indexToFocus = targetIndex;
        } else if (window.jumpToLastOnFilterChange && lastValidIndex !== -1) {
            indexToFocus = lastValidIndex;
        } else if (firstValidIndex !== -1) {
            indexToFocus = firstValidIndex;
        }

        window.jumpToLastOnFilterChange = false;

        if (indexToFocus !== -1) {
            window.executeFocusRestore(indexToFocus, false, forceSnap === true);
        }

        window.updateVisibleCount();
    }

    onCurrentFilterChanged: {
        window.isModelChanging = true;
        let returningFromSearch = (window._lastFilter === "Search" && window.currentFilter !== "Search");
        window._lastFilter = window.currentFilter;

        if (returningFromSearch) {
            window.searchIndexRestored = false;
        }

        Qt.callLater(() => {
            if (window.currentFilter === "Search" && !window.hasSearched) {
                searchInput.forceActiveFocus();
            } else {
                view.forceActiveFocus();
            }
            // view.forceActiveFocus();

            if (window.currentFilter === "Search") {
                if (window.hasSearched) {
                    window.searchIndexRestored = false;
                    window.trySearchFocus();
                }
            } else {
                window.applyFilters(returningFromSearch);
            }
            window.isModelChanging = false;
        });
    }

    // -------------------------------------------------------------------------
    // SHORTCUTS
    // -------------------------------------------------------------------------
    Shortcut {
        sequence: "Left"
        enabled: !window.isScrollingBlocked
        onActivated: window.stepToNextValidIndex(-1)
    }
    Shortcut {
        sequence: "Right"
        enabled: !window.isScrollingBlocked
        onActivated: window.stepToNextValidIndex(1)
    }
    // Shortcut {
    //     sequences: ["Return", "Enter"] // Catches both standard Enter and Numpad Enter
    //     context: Qt.ApplicationShortcut // THE NUKE: Bypasses local focus scopes completely
    //     enabled: !searchInput.activeFocus && !window.isScrollingBlocked
    //     onActivated: {
    //         let targetModel = window.getModelForFilter(window.currentFilter);
    //         if (view.currentIndex >= 0 && view.currentIndex < targetModel.count) {
    //             let fname = targetModel.get(view.currentIndex).fileName;
    //             if (fname !== undefined && fname !== "") {
    //                 let isVid = String(fname).startsWith("000_");
    //                 window.applyWallpaper(String(fname), isVid);
    //             }
    //         }
    //     }
    // }
    Shortcut {
        sequence: "Return"
        enabled: !searchInput.activeFocus && !window.isScrollingBlocked
        onActivated: {
            let targetModel = window.getModelForFilter(window.currentFilter);
            if (view.currentIndex >= 0 && view.currentIndex < targetModel.count) {
                let fname = targetModel.get(view.currentIndex).fileName;
                if (fname) {
                    // let isVid = String(fname).startsWith("000_");
                    let isVid = fname.match(/\.(mp4|mkv|webm|mov)\.jpg$/i) !== null;
                    window.applyWallpaper(String(fname), isVid);
                }
            }
        }
    }

    // Shortcut { sequence: "Escape";  onActivated: { if (window.currentFilter === "Search") window.currentFilter = "All"; } }
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (searchInput.activeFocus) {
                // 1. If typing in search, drop focus back to the grid
                view.forceActiveFocus();
            } else if (window.currentFilter === "Search") {
                // 2. If looking at search results, go back to All
                window.currentFilter = "All";
            } else {
                // 3. Otherwise, kill the entire QuickShell widget
                Qt.quit();
            }
        }
    }
    Shortcut {
        sequence: "Tab"
        onActivated: window.cycleFilter(1)
    }
    Shortcut {
        sequence: "Backtab"
        onActivated: window.cycleFilter(-1)
    }

    // -------------------------------------------------------------------------
    // CONTENT & DUAL MODELS
    // -------------------------------------------------------------------------
    ListModel {
        id: localProxyModel
    }
    ListModel {
        id: searchProxyModel
    }

    readonly property var activeModel: window.currentFilter === "Search" ? searchProxyModel : localProxyModel

    FolderListModel {
        id: localFolderModel
        folder: window.thumbDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.mp4", "*.mkv", "*.mov", "*.webm"]
        showDirs: false
        sortField: FolderListModel.Unsorted
        // sortField: FolderListModel.Name

        onCountChanged: window.syncLocalModel()
        onStatusChanged: {
            if (status === FolderListModel.Ready)
                window.syncLocalModel();
        }
    }

    function syncLocalModel() {
        let startIdx = localProxyModel.count;
        let endIdx = localFolderModel.count;

        if (endIdx < startIdx) {
            window.isModelChanging = true;
            localProxyModel.clear();
            startIdx = 0;
            window.isModelChanging = false;
        }

        for (let i = startIdx; i < endIdx; i++) {
            let fn = localFolderModel.get(i, "fileName");
            let fu = localFolderModel.get(i, "fileUrl");
            if (fn !== undefined) {
                localProxyModel.append({
                    "fileName": fn,
                    "fileUrl": String(fu)
                });
            }
        }

        if (window.currentFilter !== "Search")
            window.updateVisibleCount();

        if (!window.initialFocusSet && window.currentFilter !== "Search" && localProxyModel.count > 0) {
            window.tryFocus();
        }
    }

    FolderListModel {
        id: searchFolderModel
        folder: window.searchDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.mp4", "*.mkv", "*.mov", "*.webm"]
        showDirs: false
        sortField: FolderListModel.Name

        onFolderChanged: {
            window.isModelChanging = true;
            searchProxyModel.clear();
            window.isModelChanging = false;
        }
        onCountChanged: window.syncSearchModel()
        onStatusChanged: {
            if (status === FolderListModel.Ready)
                window.syncSearchModel();
        }
    }

    function syncSearchModel() {
        let startIdx = searchProxyModel.count;
        let endIdx = searchFolderModel.count;

        if (endIdx < startIdx) {
            window.isModelChanging = true;
            searchProxyModel.clear();
            startIdx = 0;
            window.isModelChanging = false;
        }

        for (let i = startIdx; i < endIdx; i++) {
            let fn = searchFolderModel.get(i, "fileName");
            let fu = searchFolderModel.get(i, "fileUrl");
            if (fn !== undefined) {
                searchProxyModel.append({
                    "fileName": fn,
                    "fileUrl": String(fu)
                });
            }
        }

        if (window.currentFilter === "Search")
            window.updateVisibleCount();

        if (window.currentFilter === "Search" && window.hasSearched) {
            if (!window.searchIndexRestored)
                window.trySearchFocus();

            if (window.isScrollingBlocked && startIdx === 0 && searchProxyModel.count > 0 && window.lastSearchName === "") {
                view.forceLayout();
                view.currentIndex = 0;
                view.positionViewAtIndex(0, ListView.Center);
            }
        }
    }

    // -------------------------------------------------------------------------
    // LIST VIEW — original skew / zoom / animations, untouched
    // -------------------------------------------------------------------------
    ListView {
        id: view
        anchors.fill: parent

        opacity: window.isReady ? 1.0 : 0.0
        anchors.margins: window.isReady ? 0 : 40

        Behavior on opacity {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutQuart
            }
        }
        Behavior on anchors.margins {
            NumberAnimation {
                duration: 700
                easing.type: Easing.OutExpo
            }
        }

        spacing: 0
        orientation: ListView.Horizontal
        clip: false

        interactive: !window.isScrollingBlocked
        cacheBuffer: 2000

        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width / 2) - ((window.itemWidth * 1.5 + window.spacing) / 2)
        preferredHighlightEnd: (width / 2) + ((window.itemWidth * 1.5 + window.spacing) / 2)

        highlightMoveDuration: window.initialFocusSet ? 500 : 0
        focus: true

        // Centralized Raw Input Interceptor
        Keys.onPressed: event => {
            if (window.isScrollingBlocked)
                return;

            if (event.key === Qt.Key_H) {
                window.stepToNextValidIndex(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_L) {
                window.stepToNextValidIndex(1);
                event.accepted = true;

                // === THE VIM SEARCH UPGRADE ===
            } else if (event.key === Qt.Key_Slash) {
                window.currentFilter = "Search";
                searchInput.forceActiveFocus();
                searchInput.selectAll(); // Highlights old text to easily overwrite
                event.accepted = true;
            }
        }

        onCurrentIndexChanged: {
            if (view.model !== searchProxyModel || window.currentFilter !== "Search")
                return;

            if (!window.isModelChanging && window.hasSearched && window.searchIndexRestored) {
                if (currentIndex >= 0 && currentIndex < searchProxyModel.count) {
                    let fname = searchProxyModel.get(currentIndex).fileName;
                    if (fname !== undefined && fname !== "") {
                        window.lastSearchName = String(fname);
                        searchState.lastName = String(fname);
                    }
                }
            }
        }

        add: Transition {
            enabled: window.initialFocusSet
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.5
                    to: 1
                    duration: 400
                    easing.type: Easing.OutBack
                }
            }
        }
        addDisplaced: Transition {
            enabled: window.initialFocusSet
            NumberAnimation {
                property: "x"
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        header: Item {
            width: Math.max(0, (view.width / 2) - ((window.itemWidth * 1.5) / 2))
        }
        footer: Item {
            width: Math.max(0, (view.width / 2) - ((window.itemWidth * 1.5) / 2))
        }

        model: window.activeModel

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton

            onWheel: wheel => {
                if (window.isScrollingBlocked) {
                    wheel.accepted = true;
                    return;
                }
                if (scrollThrottle.running) {
                    wheel.accepted = true;
                    return;
                }

                let dx = wheel.angleDelta.x;
                let dy = wheel.angleDelta.y;
                let delta = Math.abs(dx) > Math.abs(dy) ? dx : dy;

                scrollAccum += delta;

                if (Math.abs(scrollAccum) >= scrollThreshold) {
                    window.stepToNextValidIndex(scrollAccum > 0 ? -1 : 1);
                    scrollAccum = 0;
                    scrollThrottle.start();
                }

                wheel.accepted = true;
            }
        }

        delegate: Item {
            id: delegateRoot

            readonly property string safeFileName: fileName !== undefined ? String(fileName) : ""

            readonly property bool isCurrent: ListView.isCurrentItem && !window.isScrollingBlocked
            readonly property bool isFakeSelected: window.isScrollingBlocked && index === 0
            readonly property bool isVisuallyEnlarged: isCurrent || isFakeSelected

            // readonly property bool isVideo: safeFileName.startsWith("000_")
            readonly property bool isVideo: safeFileName.match(/\.(mp4|mkv|webm|mov)\.jpg$/i) !== null
            readonly property bool matchesFilter: window.checkItemMatchesFilter(safeFileName, isVideo, window.cacheVersion, window.currentFilter)

            readonly property real targetWidth: isVisuallyEnlarged ? (window.itemWidth * 1.5) : (window.itemWidth * 0.5)
            readonly property real targetHeight: isVisuallyEnlarged ? (window.itemHeight + 30) : window.itemHeight

            width: matchesFilter ? (targetWidth + window.spacing) : 0
            visible: width > 0.1 || opacity > 0.01
            opacity: matchesFilter ? (isVisuallyEnlarged ? 1.0 : 0.6) : 0.0

            scale: matchesFilter ? 1.0 : 0.5

            height: matchesFilter ? targetHeight : 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 15

            z: isVisuallyEnlarged ? 10 : 1

            Behavior on scale {
                enabled: window.initialFocusSet
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on width {
                enabled: window.initialFocusSet
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on height {
                enabled: window.initialFocusSet
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on opacity {
                enabled: window.initialFocusSet
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }

            Item {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: ((window.itemHeight - height) / 2) * window.skewFactor

                width: parent.width > 0 ? parent.width * (targetWidth / (targetWidth + window.spacing)) : 0
                height: parent.height

                transform: Matrix4x4 {
                    property real s: window.skewFactor
                    matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: delegateRoot.matchesFilter && !window.isScrollingBlocked
                    onClicked: {
                        view.currentIndex = index;
                        window.applyWallpaper(delegateRoot.safeFileName, delegateRoot.isVideo);
                    }
                }

                Image {
                    anchors.fill: parent
                    source: fileUrl !== undefined ? fileUrl : ""
                    sourceSize: Qt.size(1, 1)
                    fillMode: Image.Stretch
                    visible: true
                    asynchronous: true
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: window.borderWidth
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                    }
                    clip: true

                    Image {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -50
                        width: (window.itemWidth * 1.5) + ((window.itemHeight + 30) * Math.abs(window.skewFactor)) + 50
                        height: window.itemHeight + 30
                        fillMode: Image.PreserveAspectCrop
                        source: fileUrl !== undefined ? fileUrl : ""
                        asynchronous: true

                        transform: Matrix4x4 {
                            property real s: -window.skewFactor
                            matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }
                    }

                    Rectangle {
                        visible: delegateRoot.isVideo
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: 32
                        height: 32
                        radius: 6
                        color: "#60000000"
                        transform: Matrix4x4 {
                            property real s: -window.skewFactor
                            matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }

                        Canvas {
                            anchors.fill: parent
                            anchors.margins: 8
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.fillStyle = "#EEFFFFFF";
                                ctx.beginPath();
                                ctx.moveTo(4, 0);
                                ctx.lineTo(14, 8);
                                ctx.lineTo(4, 16);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // FILTER BAR — color dot buttons removed, everything else original
    // -------------------------------------------------------------------------
    Rectangle {
        id: filterBarBackground
        anchors.top: parent.top

        anchors.topMargin: window.isReady ? 40 : -100
        opacity: window.isReady ? 1.0 : 0.0
        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutExpo
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        z: 20
        height: 56
        width: filterRow.width + 24
        radius: 14

        color: Qt.rgba(_theme.mantle.r, _theme.mantle.g, _theme.mantle.b, 0.90)
        border.color: Qt.rgba(_theme.surface2.r, _theme.surface2.g, _theme.surface2.b, 0.8)
        border.width: 1

        Row {
            id: filterRow
            anchors.centerIn: parent
            spacing: 12

            // Notification / spinner drawer — original code, untouched
            Rectangle {
                id: notifDrawer
                height: 44
                property real paddingLeft: window.showSpinner ? 40 : 16
                property real targetWidth: window.showNotification ? Math.min(notifTextDrawer.implicitWidth + paddingLeft + 20, 300) : 0
                width: targetWidth
                visible: width > 0.1
                radius: 10
                clip: true

                color: window.showNotification ? Qt.rgba(_theme.surface2.r, _theme.surface2.g, _theme.surface2.b, 0.5) : "transparent"
                border.color: window.showNotification ? Qt.rgba(_theme.surface1.r, _theme.surface1.g, _theme.surface1.b, 0.8) : "transparent"
                border.width: 1

                Behavior on width {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 400
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: 400
                    }
                }

                Item {
                    visible: window.showSpinner
                    width: 44
                    height: 44
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    Canvas {
                        id: notifSpinner
                        width: 14
                        height: 14
                        anchors.centerIn: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.lineWidth = 2;
                            ctx.strokeStyle = Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.3);
                            ctx.beginPath();
                            ctx.arc(7, 7, 5, 0, Math.PI * 2);
                            ctx.stroke();
                            ctx.strokeStyle = Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.9);
                            ctx.beginPath();
                            ctx.arc(7, 7, 5, 0, Math.PI * 0.5);
                            ctx.stroke();
                        }
                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 800
                            running: window.showSpinner && window.showNotification
                        }
                    }
                }

                Text {
                    id: notifTextDrawer
                    anchors.left: parent.left
                    anchors.leftMargin: window.showSpinner ? 40 : 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, 300 - anchors.leftMargin - 16)
                    text: window.currentNotification
                    color: _theme.text
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    opacity: window.showNotification ? 0.9 : 0.0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutQuad
                        }
                    }
                    Behavior on anchors.leftMargin {
                        NumberAnimation {
                            duration: 600
                            easing.type: Easing.OutBack
                            easing.overshoot: 0.5
                        }
                    }
                }
            }

            // All + Video buttons only (no color dots)
            Repeater {
                model: window.filterData

                delegate: Item {
                    visible: modelData.name !== "Search"
                    width: !visible ? 0 : 44
                    height: !visible ? 0 : 36
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: window.currentFilter === modelData.name ? _theme.surface2 : "transparent"
                        border.color: window.currentFilter === modelData.name ? _theme.text : Qt.rgba(_theme.surface1.r, _theme.surface1.g, _theme.surface1.b, 0.6)
                        border.width: window.currentFilter === modelData.name ? 2 : 1
                        scale: window.currentFilter === modelData.name ? 1.15 : (filterMouse.containsMouse ? 1.08 : 1.0)

                        Behavior on scale {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.2
                            }
                        }
                        Behavior on border.color {
                            ColorAnimation {
                                duration: 300
                            }
                        }

                        Canvas {
                            visible: modelData.name === "All"
                            width: 14
                            height: 14
                            anchors.centerIn: parent
                            property string activeColor: window.currentFilter === modelData.name ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.7)
                            onActiveColorChanged: requestPaint()
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.fillStyle = activeColor;
                                ctx.fillRect(0, 0, 6, 6);
                                ctx.fillRect(8, 0, 6, 6);
                                ctx.fillRect(0, 8, 6, 6);
                                ctx.fillRect(8, 8, 6, 6);
                            }
                        }

                        Canvas {
                            visible: modelData.name === "Video"
                            width: 14
                            height: 16
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 2
                            property string activeColor: window.currentFilter === modelData.name ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.7)
                            onActiveColorChanged: requestPaint()
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.fillStyle = activeColor;
                                ctx.beginPath();
                                ctx.moveTo(0, 0);
                                ctx.lineTo(14, 8);
                                ctx.lineTo(0, 16);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                    }

                    MouseArea {
                        id: filterMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: window.currentFilter = modelData.name
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // Search pause/resume — original code, untouched
            Rectangle {
                id: searchControlBtn
                visible: window.currentFilter === "Search" && window.hasSearched
                width: visible ? 44 : 0
                height: 44
                radius: 10
                clip: true
                color: window.isSearchPaused ? _theme.surface2 : "transparent"
                border.color: window.isSearchPaused ? _theme.text : Qt.rgba(_theme.surface1.r, _theme.surface1.g, _theme.surface1.b, 0.6)
                border.width: window.isSearchPaused ? 2 : 1

                Behavior on width {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 400
                        easing.type: Easing.OutQuart
                    }
                }

                MouseArea {
                    id: scMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.isSearchPaused = !window.isSearchPaused
                }

                Canvas {
                    width: 44
                    height: 44
                    anchors.centerIn: parent
                    property bool paused: window.isSearchPaused
                    property string activeColor: paused ? _theme.text : (scMouse.containsMouse ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.7))
                    onActiveColorChanged: requestPaint()
                    onPausedChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = activeColor;
                        if (!paused) {
                            ctx.fillRect(15, 14, 4, 16);
                            ctx.fillRect(25, 14, 4, 16);
                        } else {
                            ctx.beginPath();
                            ctx.moveTo(16, 12);
                            ctx.lineTo(32, 22);
                            ctx.lineTo(16, 32);
                            ctx.closePath();
                            ctx.fill();
                        }
                    }
                }
            }

            // Search box — original code, untouched
            Rectangle {
                id: searchBox
                height: 44
                width: window.currentFilter === "Search" ? 360 : 44
                radius: 10
                clip: true

                color: window.currentFilter === "Search" ? Qt.rgba(_theme.surface2.r, _theme.surface2.g, _theme.surface2.b, 0.8) : "transparent"
                border.color: window.currentFilter === "Search" ? Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.5) : Qt.rgba(_theme.surface1.r, _theme.surface1.g, _theme.surface1.b, 0.6)
                border.width: window.currentFilter === "Search" ? 2 : 1

                Behavior on width {
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 400
                        easing.type: Easing.OutQuart
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: 400
                    }
                }

                MouseArea {
                    id: searchMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (window.currentFilter !== "Search") {
                            window.currentFilter = "Search";
                        } else {
                            window.currentFilter = "All";
                        }
                    }
                }

                Canvas {
                    id: searchIcon
                    width: 44
                    height: 44
                    anchors.left: parent.left
                    anchors.leftMargin: window.currentFilter === "Search" ? 5 : 0
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on anchors.leftMargin {
                        NumberAnimation {
                            duration: 500
                            easing.type: Easing.OutExpo
                        }
                    }
                    property string activeColor: window.currentFilter === "Search" ? _theme.text : (searchMouseArea.containsMouse ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.7))
                    onActiveColorChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.lineWidth = 3;
                        ctx.strokeStyle = activeColor;
                        ctx.beginPath();
                        ctx.arc(18, 18, 7, 0, Math.PI * 2);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.moveTo(23, 23);
                        ctx.lineTo(31, 31);
                        ctx.stroke();
                    }
                }

                TextInput {
                    id: searchInput
                    anchors.left: searchIcon.right
                    anchors.right: submitBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: window.currentFilter === "Search" ? 1.0 : 0.0
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutQuad
                        }
                    }
                    color: _theme.text
                    font.family: "JetBrains Mono"
                    font.pixelSize: 16
                    clip: true
                    onTextEdited: {
                        window.hasSearched = false;
                        searchState.searched = false;
                    }
                    onAccepted: {
                        window.triggerOnlineSearch();
                        searchInput.focus = false;
                        view.forceActiveFocus();
                    }
                }

                Rectangle {
                    id: submitBtn
                    width: 32
                    height: 32
                    radius: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: window.currentFilter === "Search" ? 1.0 : 0.0
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutQuad
                        }
                    }
                    color: submitMouseArea.containsMouse ? Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.1) : "transparent"
                    border.color: submitMouseArea.containsMouse ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.3)
                    border.width: 1
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }
                    }

                    MouseArea {
                        id: submitMouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            window.triggerOnlineSearch();
                        }
                    }

                    Canvas {
                        width: 16
                        height: 16
                        anchors.centerIn: parent
                        property string activeColor: submitMouseArea.containsMouse ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.7)
                        onActiveColorChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.lineWidth = 2;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";
                            ctx.strokeStyle = activeColor;
                            ctx.beginPath();
                            ctx.moveTo(2, 8);
                            ctx.lineTo(14, 8);
                            ctx.moveTo(9, 3);
                            ctx.lineTo(14, 8);
                            ctx.lineTo(9, 13);
                            ctx.stroke();
                        }
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // INIT
    // -------------------------------------------------------------------------
    Component.onCompleted: {
        Quickshell.execDetached(["bash", "-c", "mkdir -p '" + decodeURIComponent(window.searchDir.replace("file://", "")) + "'"]);
        Quickshell.execDetached(["bash", "-c", "mkdir -p '" + window.appliedDir + "'"]);

        if (searchState.searched) {
            searchInput.text = searchState.query;
            window.searchQuery = searchState.query;
            window.hasSearched = true;
            window.lastSearchName = searchState.lastName;
            window.isSearchPaused = true;
        }

        view.forceActiveFocus();
        window.updateVisibleCount();
    }

    Component.onDestruction: {
        if (window.hasSearched) {
            searchState.query = searchInput.text;
            searchState.searched = window.hasSearched;
            searchState.lastName = window.lastSearchName;
            Quickshell.execDetached(["bash", "-c", "echo 'pause' > /tmp/ddg_search_control"]);
        } else {
            Quickshell.execDetached(["bash", "-c", "echo 'stop' > /tmp/ddg_search_control; for p in $(pgrep -f ddg_search.sh); do if [ \"$p\" != \"$$\" ] && [ \"$p\" != \"$BASHPID\" ]; then kill -9 $p 2>/dev/null || true; fi; done; pkill -f '[g]et_ddg_links.py'"]);
        }
    }
}
