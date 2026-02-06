package com.project;

import java.net.URL;
import java.util.ResourceBundle;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.geometry.Pos;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;

import javafx.event.EventHandler;

public class ControllerInfoMobile implements Initializable {

    private Rectangle rectangle;

    @FXML
    public VBox infoVbox;

    @FXML
    public ImageView infoImatge;

    @FXML
    public Label titol, info, nom;

    @FXML
    public ImageView arrowBack;

    private String jsonArxiu = "";

    public String getJsonFile() {
        return jsonArxiu;
    }

    public void setJsonFile(String jsonArxiu) {
        this.jsonArxiu = jsonArxiu;
        System.out.println(jsonArxiu);
    }

    // Actualiza título principal
    public void actualizarText(String title) {
        titol.setText(title);
    }

    // Actualiza info adicional (edad del animal)
    public void actualitzarInformacio(String infoExtra) {
        info.setText(infoExtra);
        info.setWrapText(true);
    }

    // Actualiza el nombre del animal
    public void actualizarTitol(String infoExtra) {
        nom.setText(infoExtra);
        nom.setWrapText(true);
    }

    // Actualiza la imagen del animal
    public void actualizarImatge(Image img) {
        infoImatge.setImage(img);
    }

    // Crea un pequeño rectángulo con el color del animal
    public void crearRectangle(String color) {
        infoVbox.setAlignment(Pos.CENTER);

        if (color == null || color.isEmpty()) {
            if (rectangle != null) {
                infoVbox.getChildren().remove(rectangle);
                rectangle = null;
            }
            return;
        }

        if (rectangle == null) {
            rectangle = new Rectangle(20, 20);
            infoVbox.getChildren().add(rectangle);
        }
        rectangle.setFill(Color.web(color));
    }

    // Función para volver a la lista
    @FXML
    public void Enrere() {
        arrowBack.setOnMouseClicked(new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent e) {
                try {
                    UtilsViews.setViewAnimating("layoutListMobile");
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        });
    }

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        Enrere();
    }
}
