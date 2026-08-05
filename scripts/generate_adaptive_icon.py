import os
import sys

try:
    from PIL import Image
except ImportError:
    print("Pillow not found. Please run 'pip install Pillow' in your venv.")
    sys.exit(1)

def generate_adaptive_foreground():
    source_path = 'assets/images/KISTAS.png'
    target_path = 'assets/images/KISTAS_adaptive_foreground.png'
    
    if not os.path.exists(source_path):
        print(f"Error: {source_path} not found.")
        return

    print(f"Processing {source_path} for Adaptive Icon Foreground...")
    
    img = Image.open(source_path).convert("RGBA")
    
    # Adaptive Icon Foreground 108x108 dp'dir.
    # Güvenli alan merkezden itibaren yaklaşık %66'dır.
    # Biz %50 (yarı yarıya) küçülterek garantiye alıyoruz.
    
    canvas_size = (1024, 1024)
    new_img = Image.new("RGBA", canvas_size, (0, 0, 0, 0)) # Şeffaf
    
    # Logoyu %50 boyutuna getir (512px)
    target_width = 512
    w_percent = (target_width / float(img.size[0]))
    h_size = int((float(img.size[1]) * float(w_percent)))
    
    img_resized = img.resize((target_width, h_size), Image.Resampling.LANCZOS)
    
    # Ortaya yapıştır
    x_offset = (canvas_size[0] - img_resized.width) // 2
    y_offset = (canvas_size[1] - img_resized.height) // 2
    
    new_img.paste(img_resized, (x_offset, y_offset), img_resized)
    
    new_img.save(target_path)
    print(f"Success: Adaptive foreground icon saved to {target_path}")

if __name__ == "__main__":
    generate_adaptive_foreground()