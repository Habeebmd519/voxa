# Keep Jackson (fix JsonFactory issue)
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**

# Keep AutoValue (fix AutoValue error)
-keep class com.google.auto.value.** { *; }
-dontwarn com.google.auto.value.**

# OpenTelemetry (important)
-keep class io.opentelemetry.** { *; }
-dontwarn io.opentelemetry.**