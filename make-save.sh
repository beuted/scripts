#!/bin/bash

# Save stuff from my computer to external disk and raspberrypi media center
SerialNumber="5E2FF9CD"
DiskId=$(wmic logicaldisk get name, volumename, volumeserialnumber | grep $SerialNumber | cut -c1-1)
if [ -z "$DiskId" ]
then
    echo "Could not find disk with Serial" $SerialNumber
    exit 1
fi
echo "Found external disk with Serial" $SerialNumber "mounted as" $DiskId":/"

echo "Sync Images to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /d/Images/ /$DiskId/Images/
echo "Sync Images to raspberry"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /d/Images/ pi@192.168.0.17:/media/external/benoit/Images/

echo "Sync music-crea to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /f/music-crea/ /$DiskId/music-crea/
echo "Sync music-crea to raspberry"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /f/music-crea/ pi@192.168.0.17:/media/external/benoit/music-crea/

echo "Sync Musique to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /d/Musique/ /$DiskId/Musique/
echo "Sync Musique to raspberry"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /d/Musique/ pi@192.168.0.17:/media/external/benoit/Musique/

echo "Sync Ebooks to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /e/Ebooks/ /$DiskId/Ebooks/
echo "Sync Ebooks to raspberry"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /e/Ebooks/ pi@192.168.0.17:/media/external/benoit/Ebooks/

echo "Sync backups to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /e/backups/ /$DiskId/backups/
echo "Sync backups to raspberry"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /e/backups/ pi@192.168.0.17:/media/external/benoit/backups/

echo "Sync Docs to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /e/Docs/ /$DiskId/Docs/
echo "Sync Docs to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /e/Docs/ pi@192.168.0.17:/media/external/benoit/Docs/

echo "Sync TvShows to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /d/Vidéos/TvShows/ /$DiskId/TvShows/
echo "Sync TvShows to raspberry"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /d/Vidéos/TvShows/ pi@192.168.0.17:/media/external/benoit/TvShows/

echo "Sync Movies to external disk"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /d/Vidéos/Movies/ /$DiskId/Movies/
echo "Sync Movies to raspberry"
rsync -a -v --ignore-existing --info=progress2 --info=name0 /d/Vidéos/Movies/ pi@192.168.0.17:/media/external/benoit/Movies/
