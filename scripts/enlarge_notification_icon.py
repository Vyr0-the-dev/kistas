import os
import sys

try:
    from PIL import Image
except ImportError:
    print("Pillow not found. Please run 'pip install Pillow' in your venv.")
    sys.exit(1)

def enlarge_icon():
    path = 'assets/images/notification_icon.png'
    
    if not os.path.exists(path):
        print(f"Error: {path} not found.")
        return

    print(f"Opening {path}...")
    img = Image.open(path).convert("RGBA")
    
    # 1. Get bounding box of non-transparent pixels
    bbox = img.getbbox()
    if not bbox:
        print("Image is completely transparent!")
        return
        
    print(f"Original size: {img.size}")
    print(f"Content bbox: {bbox}")
    
    # 2. Crop to content
    cropped_img = img.crop(bbox)
    
    # 3. Create a new canvas slightly larger than the content (to avoid edge touching)
    # Standard recommendation for notification icons is that content should fill 
    # about 24x24dp area within a 24x24dp asset (basically full bleed with minimal padding).
    # But for generating android resources, we often use a larger source.
    # Let's target a square aspect ratio based on the largest dimension of the cropped content.
    max_dim = max(cropped_img.width, cropped_img.height)
    
    # Add a small padding (e.g., 5%) so it doesn't touch the absolute edge
    padding = int(max_dim * 0.05)
    canvas_size = max_dim + (padding * 2)
    
    new_img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    
    # Center the cropped image on the new canvas
    x_offset = (canvas_size - cropped_img.width) // 2
    y_offset = (canvas_size - cropped_img.height) // 2
    
    new_img.paste(cropped_img, (x_offset, y_offset))
    
    # 4. Save overwrite
    new_img.save(path)
    print(f"Success: Enlarged icon saved to {path} (New size: {canvas_size}x{canvas_size})")

if __name__ == "__main__":
    enlarge_icon()
