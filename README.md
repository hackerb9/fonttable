<img align="right" src="README.md.d/fonttable.gif" title="Example of fonttable running in `xterm -fa DroidSansMono -fd DroidSansFallback`"
alt="Scrolling CJK glyphs">

# fonttable
Print out every¹ unicode character; see all possible glyphs in your terminal

¹ Well... not quite *every* character. We don't want control codes
and such, so characters in categories `C`, `M`, and `Z` won't be printed. (See the table of [general category values](http://unicode.org/reports/tr44/#GC_Values_Table) at the end of the script.)
 
If you don't have [`/usr/share/unicode/UnicodeData.txt`](http://unicode.org/Public/UNIDATA/UnicodeData.txt) on your system, a version cached in this script will be automatically used. (v14.0.0, current as of September 2021 from unicode.org).

Additionally: the Unicode Consortium's ["UnicodeData.txt"](http://unicode.org/Public/UNIDATA/UnicodeData.txt) file does not list CJK characters, but they can be found in the adjacent [Unihan](http://unicode.org/Public/UNIDATA/Unihan.zip) database. If you'd like to see them as well, specify "-s" 

## Installation

It's a shell script. Just download
[`fonttable`](https://github.com/hackerb9/fonttable/blob/master/fonttable?raw=true)
and run it. 

## Notes

1. This was inspired by the favorite 8-bit one-liner of many a youth:
    <video>
    <source src="README.md.d/c64xterm.mp4" type="video/mp4">
    <img width=50% align="right" src="README.md.d/c64xterm.gif"
    alt="Scrolling C64 PETSCII" secret="You figured it out! It's actually
    xterm -fa C64ProMono" title="FORT=0TO255:?CHR$(T);:NEXT:RUN">
    </video> 

         FORT=0TO255:?CHR$(T);:NEXT:RUN 

2. This is the modern equivalent, a way to see every valid glyph.
   Of course, we can't use a simple loop since Unicode has a huge
   address space and only a small fraction of the code points are
   valid characters. The solution is to only print characters
   specified in the UnicodeData.txt file.

3. Likewise, not every CJK code point in the allocated UNIFIED
   IDEOGRAPH range is a character. Fonttable prints only characters
   that the Unihan database knows exist. (Unihan_DictionaryIndices.txt).
   
4. As of Unicode 14 (2021), I count almost 32,000 printable characters
   in UnicodeData.txt. Additionally, there are over 70,000 known CJK
   characters in the Unihan database.

        $ ./fonttable -s | awk '{print length($1)}'
        31959
        70805

    (Some people claim much higher numbers because they are using
    PropList.txt and counting *allocated* regions, whether or not
    characters exist at those code points.)

## Usage

    fonttable [ -c ] [ -s ] [ -u ] [ START..END ] 
        -c | --cache
                Use cached UnicodeData.txt embedded in this script.
                Usually the cached version is only used if the file is
                not in /usr/share/unicode/ or the current directory.
        -s | --show-unihan
                Show Chinese, Japanese, Korean data from the Unihan database.
                Default is to only show characters from UnicodeData.txt
        -u | --unihan-cache
                Use a cached copy of the list of valid CJK characters
                instead of looking for Unihan_DictionaryIndices.txt.
        START..END
            Show range from START to END, inclusive. (Hexadecimal). 
            START defaults to 0, END defaults to infinity.
            Example: fonttable 2500..90 1FB00..AF

        UnicodeData.txt contains arund 30,000 characters.
        Unihan adds another 70,000.

____

# YMMV

Different terminal programs and fonts will give you drastically
different results.

## Gnome Terminal 
<details>

Gnome-Terminal-3.18.3 appears to fall back to proportional fonts for code points not in its default font, causing it to have overlapping glyphs. There is no setting to tell it not to do this:

![Example of Gnome Terminal 3.18.3 running fonttable](/README.md.d/ss-gnome-terminal.png "Notice the overlapping glyphs")

While messy, this does have the benefit of ensuring that any Unicode character you come across will be shown. (Assuming you have a font for it, of course). 
</details>


## Xterm
<details>

Xterm does the same thing when an antialiased (vector) font is
selected, filling in with system fonts if the selected font is too
limited. Bitmaps fonts however, are trickier.

### For bitmap fonts

Xterm will use only a single font if you specify a bitmap font using
`-fn`. That means you'll need to find one font that covers every
section of Unicode you use. This can be rather tricky.


The default xterm font, called "fixed", seems a terrible choice as it
has very few Unicode characters. However, that is because xterm uses
the Latin-1 version by default. There is a Unicode (10646) version of
"fixed" which is not bad in terms of coverage. "Fixed" also comes in a
wide version for Asian characters, which xterm automatically detects
and uses. So, not a bad choice, and it comes pre-installed.

    xterm  -fn '*fixed-medium-r-normal--20*10646*' 
    
![Example of XTerm(322) running fonttable with neep](/README.md.d/ss-xterm-neep.png "Technically, this is the 'neep' font, which I prefer to 'fixed', but requires you to install xfonts-jmk")

### For antialiased fonts

XTerm already fills in missing glyphs for you by using other fonts
when you specify an antialiased font using `-fa`. Use `-fs` to specify
the point size. Note: "Antialiased" is how XTerm refers to vector
fonts like TrueType, OpenType, and Type 1.

If you wish to see which fonts are getting loaded as you run
fonttable, set the XFT_DEBUG environment variable to 3 before running
xterm. 

    XFT_DEBUG=3 xterm -fa DroidSansMono -fs 24

If you wish to force xterm to use *only* the fonts you requested, you
can do so by setting the `limitFontsets` X resource to 0.

    xterm -fa DroidSansMono -xrm "XTerm*vt100.limitFontsets: 0"
    
Note that xterm will attempt to automatically detect if your font is
also available in a doublesize version (for CJK). If it doesn't find
it, you can specify a separate "doublesize" font using `-fd`.

    xterm -fs 24 -fa DroidSansMono -fd DroidSansFallback -xrm "XTerm*vt100.limitFontsets: 0"
    
Note that if you don't have a particular font installed, even if you
use limitFontsets: 0, you will be shown a substitute font. Again, you
can use XFT_DEBUG to find out what is going on.

    XFT_DEBUG=3 xterm -fs 24 -fa DroidSansMono -fd DroidSansFallback -xrm "XTerm*vt100.limitFontsets: 0"
    


![Example of XTerm(322) running fonttable with DroidSansMono](/README.md.d/ss-xterm-droidsans.png "fonttable demonstrating DroidSansFallback being used by xterm as a double-size font")

</details>

