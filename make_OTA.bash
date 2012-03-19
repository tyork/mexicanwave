#!/bin/bash -ue

targetPLIST=OTA.plist

# Get the build number from the command line arguments and configure the OTA URL
if [ $# -eq 4 ] 
then
	# TODO: support localizations for the relevant plist keys
	# TODO: (perhaps) identify the application plist automatically
	infoPLIST=$1
	companyName=$2
	# TODO: get this from bundle
	ipaName=$3
	jobURL=$4
	
else
	# Exit with failure
	echo 'Expected arguments: <info_plist_path_and_name> <company_name> <ipa_name> <job_url>'
	false
fi

# Build the URL to the artifacts
OTAURL=$jobURL

# Extract the application-specific content from the application's Info plist
bundleIdentifier=`/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' $infoPLIST`
bundleVersion=`/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' $infoPLIST`
appName=`/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' $infoPLIST`
appIcon=`/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFiles:0' $infoPLIST`

#ipaName=`/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' $infoPLIST | sed -e s/.app/.ipa/`

# Figure out if we need shine on the various icons
if grep -q "UIPrerenderedIcon" $infoPLIST
then
  if [ $(/usr/libexec/PlistBuddy -c 'Print :UIPrerenderedIcon' $infoPLIST) == "true" ]
  then
    # Prerender key indicates true, don't need shine
    needsShine='<false/>'
  else
    # Prerender key is false, need shine
    needsShine='<true/>'
  fi
else 
  # Prerender key doesn't exist - needs shine.
  needsShine='<true/>'
fi

# Generate the OTA PLIST, filling in missing bits from the various variables extracted above.
cat << EOF > $targetPLIST
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>items</key>
   <array>
       <dict>
           <key>assets</key>
           <array>
               <dict>
                   <key>kind</key>
                   <string>software-package</string>
                   <key>url</key>
                   <string>$OTAURL/$ipaName</string>
               </dict>
               <dict>
                   <key>kind</key>
                   <string>display-image</string>
                   <key>needs-shine</key>
                   $needsShine
                   <key>url</key>
                   <string>$OTAURL/$appIcon</string>
               </dict>
               <dict>
                   <key>kind</key>
                   <string>full-size-image</string>
                   <key>needs-shine</key>
                   $needsShine
                   <key>url</key>
                   <string>$OTAURL/itunesArtwork</string>
               </dict>
           </array>
           <key>metadata</key>
           <dict>
               <key>bundle-identifier</key>
               <string>$bundleIdentifier</string>
               <key>bundle-version</key>
               <string>$bundleVersion</string>
               <key>kind</key>
               <string>software</string>
               <key>title</key>
               <string>$appName</string>
               <key>subtitle</key>
               <string>$companyName</string>
           </dict>
       </dict>
   </array>
</dict>
</plist>
EOF

# If the itunesArtwork isn't available then just remove that part of the OTA plist entirely.
if [ ! -e "itunesArtwork" ]; then
  /usr/libexec/PlistBuddy -c "Delete :items:0:assets:2" $targetPLIST
fi  


############ Make the HTML file

# Encode the URL to the OTA plist
OTAmanifestURL=$OTAURL'/'$targetPLIST
#encodedManifestURL="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$OTAmanifestURL")"
encodedManifestURL="$(echo $OTAmanifestURL | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')"

htmlPageText='<!DOCTYPE HTML>
<html>
<head>
<title>Install this application</title>
</head>
<body>
<p>
<a href="itms-services://?action=download-manifest&url='$encodedManifestURL'">Tap to download the application.</a>
</p>
</body>
</html>' 

echo $htmlPageText > OTA.html
