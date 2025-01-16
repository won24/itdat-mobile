# Flutter에서 사용되는 기본 ProGuard 설정
-keepattributes *Annotation*
-keepattributes InnerClasses

# HTTP 및 네트워크 보안 관련 규칙
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }

# HTTP 라이브러리 관련 설정 (필요한 경우만 추가)
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.** { *; }

# Dio 라이브러리 관련 설정
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class javax.inject.** { *; }
-dontwarn javax.annotation.**

# Google Play Core 라이브러리 유지
-keep class com.google.android.play.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Conscrypt 관련 클래스 유지
-keep class org.conscrypt.** { *; }

# OpenJSSE 관련 클래스 유지
-keep class org.openjsse.** { *; }

# Flutter 관련 유지 규칙
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# 의존성 관련 유지 규칙 (vibration, uni_links 등)
-keep class com.benjaminabel.vibration.** { *; }
-keep class name.avioli.unilinks.** { *; }

# 기본적으로 모든 Firebase 클래스 유지
-keep class com.google.firebase.** { *; }

# OkHttp 관련 클래스 유지
-keep class okhttp3.** { *; }
-keepclassmembers class okhttp3.** { *; }
-dontwarn okhttp3.**

# javax.net.ssl 관련 클래스 유지
-keep class javax.net.ssl.** { *; }
