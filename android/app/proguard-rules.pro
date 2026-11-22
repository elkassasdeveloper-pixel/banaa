# Flutter Wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class io.flutter.provider.**  { *; }
-keep class io.flutter.binder.**  { *; }

# Flutter Plugins
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.transistorsoft.flutter.** { *; }

# R8 Obfuscation & Shrinking Settings
-repackageclasses ''
-allowaccessmodification
-dontwarn android.webkit.**
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn com.google.android.play.core.**
