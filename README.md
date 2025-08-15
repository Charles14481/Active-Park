# active_park

My app connects people looking for spots with people who will be leaving soon. Take one user with a parked car, who is finishing up whatever they are doing. When they are a few minutes away from their car, they can make a post to the app that lets nearby users know that a spot there will open soon. Another user can reserve the spot for a few credits and start making their way there. After the swap occurs, the poster will get credits they can spend on a spot in the future. This has a few key advantages to traditional waiting. For instance, it gives people more confidence in their options. Instead of dealing with probabilities that a spot will show up, you are guaranteed spots and can weigh your options with more information. Additionally, using the app requires less effort. Instead of having everyone in your car scan for spots as you drive around your destination, you have one destination that you go to.

Images of the app and a demo video can be found in the media folder.

# To run yourself:
Obtain a [Google Cloud API Key](https://console.cloud.google.com/apis/credentials?)
Create a `secrets.json` folder inside the `libs\configs` folder. Structure it as follows:
```
{
  "google_maps": "<insert key here>"
}
```
Also add the `AndroidManifest.xml` file to `android\app\src\main\AndroidManifest.xml` with your API key:
```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.charles.active_park">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <application
        android:label="active_park"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <meta-data android:name="com.google.android.geo.API_KEY"
                android:value="<insert key here>"/>

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text, see:
         https://developer.android.com/training/package-visibility and
         https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.
         In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

