# roadkill

A driving game that was never released to production.
RKDEATH appears to be the newest(?) version.
Precompiled objects can be turned into game/gfx roms with the batch files.

## Required tools:
- Dosbox 0.74 or higher (set files= in conf..) [download](https://www.dosbox.com/download.php?main=1)
- Optional files= patch [download](https://www.shdon.com/blog/2009/09/05/adjustable-files-setting-in-dosbox)
- Srec_Cat for MS Windows[download](https://srecord.sourceforge.net/download.html)
- DD for MS Windows [download](http://www.chrysocome.net/dd)

Install Dosbox, put the command line tools in your path. If you don't know how to do that, this is not a project for you.

## Known issues:
- RKDEATH\DR.OUT does not match up with the IRW data and seems earlier release.
- RK\AP.OUT does not match up with the IRW data and seems another earlier release.
- RK\DR.OUT does not match up with the IRW data and seems another earlier release.

# To build stuff under dosbox:
- Add TI folder to your path. See readme.md there.
- Open dosbox, change to the mk2 src folder.