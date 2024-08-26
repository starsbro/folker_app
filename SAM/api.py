#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from fastapi import FastAPI, UploadFile, File
from segment_anything import sam_model_registry, SamPredictor
from PIL import Image
import numpy as np
import io

app = FastAPI()

sam = sam_model_registry["vit_h"](checkpoint="./segment-anything/checkpoint/sam_vit_h_4b8939.pth")
predictor = SamPredictor(sam)

@app.post("/predict/")
async def predict_mask(file: UploadFile = File(...), x: int = 0, y: int = 0):
    image = Image.open(io.BytesIO(await file.read()))
    image_np = np.array(image)
    predictor.set_image(image_np)

    input_point = np.array([[500,300]])
    input_label = np.array([1])

    masks, _, _ = predictor.predict(point_coords=input_point, point_labels=input_label, multimask_output=True)

    return {"mask": masks[0].tolist()}

