# AppleScript

## Introduction

At some point, computer users tend to find themselves having to repeat a task
over and over again, such as deleting old messages from their e-mail inbox, or
fixing the information associated with tracks in a media player. Power-users
then look for a way to automate these jobs, and coders tend to do this by
writing scripts. And OSX users have AppleScript.

Of course, OSX being a Unix derivative, shell scripts are also useful for
automating tasks in that environment, but to interact with the most common
applications, AppleScript bridges the gap between the closed-source programmes
and the user.

I started to explore AppleScript when I needed to delete tracks from iTunes
for which the files no longer existed (you know, those with the little
exclamation mark next to them), and using the GUI was far too cumbersome. It
turned out to be (almost) trivial.

This short document outlines my experiences with the language, its tools, its
power and its limitations. It's aimed at people with some programming
experience, particularly with a scripted language such as Perl or Python. The
examples herein should run on any computer that has osascript(1) available (so,
most likely, only Apple Mac).

## The Language

AppleScript (the language) is a little strange. It's designed to read rather
like English[1]. For example:

```applescript
tell application "iTunes" to play the first track in the playlist "Music"
```

does something unsurprising. However, this expressiveness comes at a cost; it
can be awkward to build up useful commands if you're used to other scripting
languages.

As I mentioned, it's all about sending Apple events around. I'll go into more
details on Apple events later, but for now you can think of them as objects with
a given type and some nested information. There's a 


What's _really_ happening in that command is that you are sending a message to
the `application "iTunes"` (that evaluates to something that can receive an
Apple event). That message is `play the first track in the playlist "Music"`.



