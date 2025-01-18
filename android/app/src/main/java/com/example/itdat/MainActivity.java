package com.itdat.store.itdat;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.nfc.NfcAdapter;
import java.util.HashMap;
import java.util.Map;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String NFC_CHANNEL = "com.itdat.store.itdat/nfc";
    private static final String META_CHANNEL = "com.itdat.store.itdat/meta_data";
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
        setIntent(intent);

        if (intent != null && intent.getData() != null) {
            String uri = intent.getData().toString();
            System.out.println("Received URI in onNewIntent: " + uri);

            if (uri.startsWith("myapp://main")) {
                String token = intent.getData().getQueryParameter("token");

                if (token != null) {
                    System.out.println("Extracted token: " + token);

                    // Flutter로 전달
                    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "redirect_uri_channel")
                            .invokeMethod("onLoginSuccess", token);
                } else {
                    System.err.println("Token이 null입니다.");
                }
            } else if (uri.startsWith("myapp://register")) {
                String providerId = intent.getData().getQueryParameter("providerId");
                String email = intent.getData().getQueryParameter("email");

                if (providerId != null && email != null) {
                    System.out.println("ProviderId: " + providerId + ", Email: " + email);

                    Map<String, String> data = new HashMap<>();
                    data.put("providerId", providerId);
                    data.put("email", email);

                    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "redirect_uri_channel")
                            .invokeMethod("onRegister", data);
                } else {
                    System.err.println("providerId 또는 email이 null입니다.");
                }
            } else {
                System.out.println("Unhandled URI: " + uri);
            }
        } else {
            System.out.println("No Intent Data Found");
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