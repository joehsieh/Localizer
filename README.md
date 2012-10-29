# Localizer #

A tool for maintaining a localized Cocoa app.

* 2012 © Joe Hsieh
* <joehsieh@kkbox.com>

## Motivation ##

Apple has a great architecture for internationalization and
localization, however, maintaining a localized iOS or Mac application
is still a pain.

Apple has a tool, genstring, which helps you to extract strings need
to be localized from your source code, and generate a string-pair
map. The tool is nice if you are working on an application which is
never localized.

In real world, what you are doing daily is maintaining an existing
localization text file, and check if there is addition or deletion of
the strings need to be localized if you ever change your source
code. What genstring does is to generate a new file, but you do not
want a new file, and to translate all of the strings in your project
every time.

What you really want is a tool, which knows these changes.

That is what the **Localizer** app tries to solve.

## The Workflow ##

Localizer is an editor for your "Localizable.strings" files, like any
other document-based applications.

Just open your existing files, add new files or folders of your source
code, then simply click on the "Scan" button on the toolbar. After
scanning, new strings will be in blue, while the strings ever
localized but deleted from source code will be in red.

Then, you can translate these strings from the table user interface,
and save the file for furthur use. Localizer remembers where these
strings are from, and the paths of your scan folders and files.

## Requirement ##

* Mac OS X 10.7
* Xcode

## How to Build the Project? ##

* Download Xcode. Xcode is available on Mac App Store and Apple
  Developer Connection.
* Open Localizer.xcodeproj with Xcode.
* Click on the "Run" button.

Enjoy it!

