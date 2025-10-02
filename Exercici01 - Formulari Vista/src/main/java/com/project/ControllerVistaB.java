package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;

public class ControllerVistaB {

    @FXML
    private Label lblSaludo;

    @FXML
    private Button btnVolver;

    public void mostrarSaludo() {
        lblSaludo.setText("Hola " + Main.nom + ", tienes " + Main.edat + " años!");
    }

    @FXML
    private void volver() {
        UtilsViews.setView("VistaA");
    }
}
