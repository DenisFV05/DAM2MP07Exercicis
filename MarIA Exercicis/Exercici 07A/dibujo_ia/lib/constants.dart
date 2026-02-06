const tools = [
  {
    "type": "function",
    "function": {
      "name": "draw_circle",
      "description":
          "Dibuixa un cercle amb un radi determinat en una posició x,y",
      "parameters": {
        "type": "object",
        "properties": {
          "x": {"type": "number", "description": "Posició X del centre"},
          "y": {"type": "number", "description": "Posició Y del centre"},
          "radius": {"type": "number", "description": "Radi del cercle"},
          "color": {"type": "string", "description": "Color hex (ex. #FF0000) o nom (ex. red). Opcional"},
          "filled": {"type": "boolean", "description": "Si ha d'estar ple de color. Opcional"}
        },
        "required": ["x", "y", "radius"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_line",
      "description":
          "Dibuixa una línia entre dos punts",
      "parameters": {
        "type": "object",
        "properties": {
          "startX": {"type": "number"},
          "startY": {"type": "number"},
          "endX": {"type": "number"},
          "endY": {"type": "number"},
          "color": {"type": "string", "description": "Color hex o nom. Opcional"},
          "width": {"type": "number", "description": "Gruix de la línia. Opcional"}
        },
        "required": ["startX", "startY", "endX", "endY"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_rectangle",
      "description":
          "Dibuixa un rectangle definit per les coordenades superior-esquerra i inferior-dreta",
      "parameters": {
        "type": "object",
        "properties": {
          "topLeftX": {"type": "number"},
          "topLeftY": {"type": "number"},
          "bottomRightX": {"type": "number"},
          "bottomRightY": {"type": "number"},
          "color": {"type": "string", "description": "Color hex o nom. Opcional"},
          "filled": {"type": "boolean", "description": "Si ha d'estar ple. Opcional"}
        },
        "required": ["topLeftX", "topLeftY", "bottomRightX", "bottomRightY"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_text",
      "description":
          "Escriu un text en una posició determinada",
      "parameters": {
        "type": "object",
        "properties": {
          "x": {"type": "number"},
          "y": {"type": "number"},
          "text": {"type": "string", "description": "Text a escriure"},
          "color": {"type": "string", "description": "Color hex o nom. Opcional"},
          "fontSize": {"type": "number", "description": "Mida de la font. Opcional"}
        },
        "required": ["x", "y", "text"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "clear_canvas",
      "description": "Esborra tot el contingut del canvas",
      "parameters": {
        "type": "object",
        "properties": {},
      }
    }
  }
];
