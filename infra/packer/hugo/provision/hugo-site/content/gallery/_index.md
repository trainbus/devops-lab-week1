---
title: "Family Gallery"
date: 2025-11-05T12:30:00Z
description: "A private gallery of cherished family moments."
params:
  icloud_album_url: "https://www.icloud.com/sharedalbum/#B0aGWZmrRGZRiRW"
---

Our private gallery automatically syncs photos from a shared family iCloud album.

**iCloud Integration Instructions:**
1. From your iPhone, create or open a Shared Album in the Photos app.
2. Share the album with family, copy the **public link** (see below).
3. Use our sync tool to pull photos and metadata into the site.

> **Currently synced with:**  
> [Apple Shared Album](https://www.icloud.com/sharedalbum/#B0aGWZmrRGZRiRW)

#### Automated Sync

_Photos and captions are synced regularly using the `icloudAlbum2hugo` utility (see below). Only those shared by the family are displayed, with optional privacy-level location fuzzing._

---

#### How to Import from iCloud or iPhone Family Sharing

1. **Set up Shared Albums:**  
   - On iOS: `Settings > [your name] > iCloud > Photos > Shared Albums` ON.  
   - In Photos app, tap `+` in Shared Albums, invite family, and copy album link.
2. **Use `icloudAlbum2hugo` for Hugo Integration:**  
   - Install Rust and the tool (`cargo install icloudAlbum2hugo`).
   - Run `icloudAlbum2hugo init` then update the `album_url` field in `config.yaml`.
   - Sync: `icloudAlbum2hugo sync`.

**Directory Structure:**

