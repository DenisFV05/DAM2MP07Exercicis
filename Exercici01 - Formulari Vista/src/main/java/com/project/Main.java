package com.project;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

public class Main extends Application {

    final int WINDOW_WIDTH = 800;
    final int WINDOW_HEIGHT = 600;

    // Variables estáticas para compartir datos
    public static String nom = "";
    public static int edat = 0;

    @Override
    public void start(Stage stage) throws Exception {

        UtilsViews.parentContainer.setStyle("-fx-font: 14 arial;");

        // Añadimos las vistas
        UtilsViews.addView(getClass(), "VistaA", "/assets/vistaA.fxml");
        UtilsViews.addView(getClass(), "VistaB", "/assets/vistaB.fxml");

        Scene scene = new Scene(UtilsViews.parentContainer);

        stage.setScene(scene);
        stage.setTitle("Ejercicio 01 - Vistas");
        stage.setMinWidth(WINDOW_WIDTH);
        stage.setMinHeight(WINDOW_HEIGHT);
        stage.show();

        // Cambiamos a la primera vista al iniciar
        UtilsViews.setView("VistaA");

        // Icono solo si no es Mac
        if (!System.getProperty("os.name").contains("Mac")) {
            Image icon = new Image("file:/icons/icon.png");
            stage.getIcons().add(icon);
        }
    }

    public static void main(String[] args) {
        launch(args);
    }
}
