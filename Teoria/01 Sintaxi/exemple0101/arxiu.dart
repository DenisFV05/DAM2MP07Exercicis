void main() {
  // Crear una llista amb exemples de diferents tipus de dades
  var dades = [
    {"tipus": "int", "valor": 123},
    {"tipus": "double", "valor": 3.14},
    {"tipus": "string", "valor": "Hola, món!"},
    {"tipus": "bool", "valor": true},
    {
      "tipus": "list",
      "valor": [1, 2, 3]
    },
    {
      "tipus": "tuple",
      "valor": [1, 2, 3]
    }, // Dart no té tuples natius, usar llistes
    {
      "tipus": "set",
      "valor": {1, 2, 3}
    },
    {
      "tipus": "map",
      "valor": {"clau": "abc"}
    }
  ];

  // Iterar a través de la llista i imprimir cada tipus de dada amb el seu valor
  for (var item in dades) {
    print("Tipus: ${item['tipus']}, Valor: ${item['valor']}");
  }
}
