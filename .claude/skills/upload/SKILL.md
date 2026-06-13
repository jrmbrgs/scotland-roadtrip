---
name: upload
description: Upload photos from upload/tosend/ to Cloudinary, tagged by folder name
user_invocable: true
---

Run the upload script to send photos to Cloudinary.

Steps:
1. List the contents of `upload/tosend/` to show which folders/photos are pending
2. If there are photos to send, run `./upload/upload.sh` from the project root
3. Show a summary of what was uploaded and any errors
4. If no photos are found in `upload/tosend/`, tell the user to add photos in subfolders (e.g. `upload/tosend/skye/photo.jpg`)
