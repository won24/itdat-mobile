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
