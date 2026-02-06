package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;

public class ControllerVistaA {

    @FXML
    private TextField txtNom;

    @FXML
    private TextField txtEdat;

    @FXML
    private Button btnEnviar;

    @FXML
    private void enviar() {
        String nom = txtNom.getText();
        String edatStr = txtEdat.getText();

        if (!nom.isEmpty() && !edatStr.isEmpty()) {
            try {
                int edat = Integer.parseInt(edatStr);
                // Guardamos en variables estáticas de Main
                Main.nom = nom;
                Main.edat = edat;

                // Obtenemos el controlador de la VistaB
                ControllerVistaB ctrlB = (ControllerVistaB) UtilsViews.getController("VistaB");
                ctrlB.mostrarSaludo(); // Actualizamos el texto de la vista B

                // Cambiamos a la VistaB
                UtilsViews.setView("VistaB");

            } catch (NumberFormatException e) {
                System.out.println("La edad debe ser un número.");
            }
        }
    }
}
