IDENTITY="Developer ID Application: Anthony Martin (DD9R5N89H9)"
FRAMEWORK_LOC="${BUILT_PRODUCTS_DIR}"/"${FRAMEWORKS_FOLDER_PATH}"
codesign --verbose --force --sign "$IDENTITY" "$FRAMEWORK_LOC/CocoaAsyncSocket.framework/Versions/A"
codesign --verbose --force --sign "$IDENTITY" "$FRAMEWORK_LOC/CocoaHTTPServer.framework/Versions/A"
codesign --verbose --force --sign "$IDENTITY" "$FRAMEWORK_LOC/CocoaLumberjack.framework/Versions/A"
codesign --verbose --force --sign "$IDENTITY" "$FRAMEWORK_LOC/LastFMAPI.framework/Versions/A"
codesign --verbose --force --sign "$IDENTITY" "$BUILT_PRODUCTS_DIR/$FULL_PRODUCT_NAME"