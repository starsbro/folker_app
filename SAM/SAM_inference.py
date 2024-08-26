#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from segment_anything import sam_model_registry, SamPredictor
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import os

os.environ["OMP_NUM_THREADS"] = "1"
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"

sam = sam_model_registry["vit_h"](checkpoint="./segment-anything/checkpoint/sam_vit_h_4b8939.pth")
predictor = SamPredictor(sam)

image = Image.open("./image/img01.jpg") 
image_np = np.array(image)
predictor.set_image(image_np)

input_point = np.array([[500,300]])  
input_label = np.array([1])

masks, scores, logits = predictor.predict(
    point_coords=input_point,
    point_labels=input_label,
    multimask_output=True,
)

plt.imshow(masks[0])
plt.show()
plt.imsave("./image/output_mask.jpg", masks[0])

