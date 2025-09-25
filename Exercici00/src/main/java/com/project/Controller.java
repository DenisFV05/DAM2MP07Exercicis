package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.event.ActionEvent;

public class Controller {

    @FXML
    private Button buttonEquals;

    @FXML
    private Button suma;

    @FXML
    private Button resta;

    @FXML
    private Button multi;

    @FXML
    private Button divi;

    @FXML
    private TextField pantalla;

    //Variables para la pantalla
    private double num1; // Primer numero en la operacion
    private String operador=""; 

    @FXML
    private void clearPantalla(ActionEvent event) {
        pantalla.clear();
        operador = "";
        num1 = 0;
    }

    @FXML
    private void insertarNumero(ActionEvent event) {
        Button btn = (Button) event.getSource();
        pantalla.appendText(btn.getText()); // Añade el número al TextField
    }

    @FXML
    private void operar(ActionEvent event) {
        Button btn = (Button) event.getSource();
        prepararOperacion(btn.getText());
    }


    private void prepararOperacion(String op) { //Esta funcion se ejecuta cuando hay que cambiar de num1 a num2
        try {
            num1 = Double.parseDouble(pantalla.getText()); // Pilla texto de la pantalla de la calculadora
            operador = op;
            pantalla.clear();  // Limpiar para escribir el segundo número
        } catch (NumberFormatException e) { // Si falla algo o lo que se introduce no es un numero
            pantalla.setText("Error");
        }
    }

    @FXML
    private void actionAdd(ActionEvent event) {
        if (operador.isEmpty()) {
            return;  // No hay operación seleccionada
        }

        try {
            double num2 = Double.parseDouble(pantalla.getText()); //Segundo numero
            double resultado = 0; // Resultado

            switch (operador) {
                case "+":
                    resultado = num1 + num2;
                    break;
                case "-":
                    resultado = num1 - num2;
                    break;
                case "*":
                    resultado = num1 * num2;
                    break;
                case "/":
                    if (num2 == 0) {
                        pantalla.setText("Error: Div/0");
                        return;
                    }
                    resultado = num1 / num2;
                    break;
            }

            pantalla.setText(String.valueOf(resultado));
            operador = "";  // Reinicia la operación
            

        } catch (NumberFormatException e) {
            pantalla.setText("Error");
        }
        
    }
}
