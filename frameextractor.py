import cv2
import os

try:
    import numpy as np
    numpy_available = True
except ImportError:
    print("NumPy non è installato. Alcune funzionalità potrebbero non essere disponibili.")
    print("Per installare NumPy eseguire: pip install numpy")
    numpy_available = False

# Percorso dell'immagine caricata
image_path = "/Users/roccogeremiaciccone/Downloads/4ee63cad63d43ccf83fd77b7ee594e28.jpg"

# Caricare l'immagine
sprite_sheet = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)

# Controllare se l'immagine è stata caricata correttamente
if sprite_sheet is None:
    raise ValueError("Errore nel caricamento dell'immagine")

# Dimensioni della spritesheet
sheet_height, sheet_width, _ = sprite_sheet.shape

# Supponiamo che l'immagine sia una griglia 4x3 (12 frame)
rows = 3  # Numero di righe
cols = 4  # Numero di colonne

# Calcolare la dimensione di ogni frame
frame_width = sheet_width // cols
frame_height = sheet_height // rows

# Creare una cartella per salvare i frame estratti
output_dir = "/Users/roccogeremiaciccone/Downloads/frames"
os.makedirs(output_dir, exist_ok=True)

# Estrarre e salvare i frame
frame_paths = []
for row in range(rows):
    for col in range(cols):
        # Calcolare le coordinate di ritaglio
        x = col * frame_width
        y = row * frame_height
        frame = sprite_sheet[y:y+frame_height, x:x+frame_width]

        # Salvare il frame
        frame_filename = f"{output_dir}/frame_{row}_{col}.png"
        cv2.imwrite(frame_filename, frame)
        frame_paths.append(frame_filename)

# Restituire l'elenco dei frame estratti
frame_paths
