import os
from PIL import Image

src_icon = "public/assets/icons/icon-512.png"
res_dir = "android/app/src/main/res"

if not os.path.exists(src_icon):
    print("Source icon not found:", src_icon)
    exit(1)

img = Image.open(src_icon).convert("RGBA")

densities = {
    "mipmap-mdpi": (48, 108),
    "mipmap-hdpi": (72, 162),
    "mipmap-xhdpi": (96, 216),
    "mipmap-xxhdpi": (144, 324),
    "mipmap-xxxhdpi": (192, 432),
}

for folder, (size, fg_size) in densities.items():
    d = os.path.join(res_dir, folder)
    os.makedirs(d, exist_ok=True)
    # ic_launcher & round
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(os.path.join(d, "ic_launcher.png"))
    resized.save(os.path.join(d, "ic_launcher_round.png"))
    
    # foreground: center the icon with padding for adaptive icons
    fg = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))
    icon_inner = img.resize((int(fg_size * 0.65), int(fg_size * 0.65)), Image.Resampling.LANCZOS)
    offset = (int((fg_size - icon_inner.width) / 2), int((fg_size - icon_inner.height) / 2))
    fg.paste(icon_inner, offset, icon_inner)
    fg.save(os.path.join(d, "ic_launcher_foreground.png"))

# Generate splash screen for port and land
splash_sizes = {
    "drawable-port-mdpi": (320, 480),
    "drawable-port-hdpi": (480, 800),
    "drawable-port-xhdpi": (720, 1280),
    "drawable-port-xxhdpi": (960, 1600),
    "drawable-port-xxxhdpi": (1280, 1920),
    "drawable-land-mdpi": (480, 320),
    "drawable-land-hdpi": (800, 480),
    "drawable-land-xhdpi": (1280, 720),
    "drawable-land-xxhdpi": (1600, 960),
    "drawable-land-xxxhdpi": (1920, 1280),
}

bg_color = (246, 241, 228, 255) # #F6F1E4

for folder, (w, h) in splash_sizes.items():
    d = os.path.join(res_dir, folder)
    os.makedirs(d, exist_ok=True)
    splash = Image.new("RGBA", (w, h), bg_color)
    logo_size = int(min(w, h) * 0.35)
    logo = img.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
    offset = (int((w - logo_size) / 2), int((h - logo_size) / 2))
    splash.paste(logo, offset, logo)
    splash.save(os.path.join(d, "splash.png"))

# Default drawable splash
splash_default = Image.new("RGBA", (480, 800), bg_color)
logo_default = img.resize((160, 160), Image.Resampling.LANCZOS)
splash_default.paste(logo_default, (160, 320), logo_default)
splash_default.save(os.path.join(res_dir, "drawable", "splash.png"))

print("All Android icons and splash screens generated successfully!")
