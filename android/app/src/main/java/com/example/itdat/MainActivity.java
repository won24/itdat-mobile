package com.example.itdat;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.nfc.NfcAdapter;
import android.util.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String NFC_CHANNEL = "com.example.itdat/nfc";
    private static final String META_CHANNEL = "com.example.itdat/meta_data";
    private static final String REDIRECT_URI_CHANNEL = "redirect_uri_channel";

    private MethodChannel nfcChannel;
    private MethodChannel metaChannel;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // NFC 관련 MethodChannel 설정
        nfcChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), NFC_CHANNEL);
        nfcChannel.setMethodCallHandler((call, result) -> {
            if ("handleNfcIntent".equals(call.method)) {
                handleNfcIntent(getIntent());
                result.success(null);
            } else {
                result.notImplemented();
            }
        });

        // Meta-data 관련 MethodChannel 설정
        metaChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), META_CHANNEL);
        metaChannel.setMethodCallHandler((call, result) -> {
            if ("getMetaData".equals(call.method)) {
                String key = call.argument("key");
                if (key != null) {
                    try {
                        PackageManager packageManager = getPackageManager();
                        android.content.pm.ApplicationInfo appInfo = packageManager.getApplicationInfo(getPackageName(), PackageManager.GET_META_DATA);
                        String value = appInfo.metaData.getString(key);
                        result.success(value);
                    } catch (Exception e) {
                        result.error("ERROR", "Failed to get meta-data for key: " + key, null);
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Key is required", null);
                }
            } else {
                result.notImplemented();
            }
        });

        // Redirect URI 관련 MethodChannel 설정
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), REDIRECT_URI_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if ("onRedirectUriReceived".equals(call.method)) {
                        String uri = getIntent() != null ? getIntent().getDataString() : null;
                        if (uri != null) {
                            result.success(uri); // Redirect URI 반환
                        } else {
                            result.error("ERROR", "No redirect URI received", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent); // 새로운 Intent 저장
        if (intent != null && intent.getData() != null) {
            String uri = intent.getData().toString();
            Log.d("RedirectURI", "Received URI: " + uri);
            // Redirect URI 전달
            new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), REDIRECT_URI_CHANNEL)
                    .invokeMethod("onRedirectUriReceived", uri);
        } else {
            Log.d("RedirectURI", "No URI received in onNewIntent");
        }
    }

    private void handleNfcIntent(Intent intent) {
        if (NfcAdapter.ACTION_NDEF_DISCOVERED.equals(intent.getAction())) {
            if (nfcChannel != null) {
                nfcChannel.invokeMethod("handleNfcIntent", null);
            }
        }
    }
}
