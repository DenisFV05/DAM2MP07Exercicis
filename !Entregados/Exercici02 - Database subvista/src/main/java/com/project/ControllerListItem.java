package com.project;

import java.net.URL;
import java.util.Objects;
import java.util.ResourceBundle;

import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.AnchorPane;

public class ControllerListItem implements Initializable {

    @FXML
    private AnchorPane infoPane;

    @FXML
    private Label title;

    @FXML
    private ImageView img;

    private String info;   // Aquí guardaremos la edad
    private String color;  // Aquí guardaremos el color del animal

    public void setInfo(String info) {
        this.info = info;
    }

    public void setColor(String color) {
        this.color = color;
    }

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        initMouseEvents();
    }

    public void setTitle(String text) {
        title.setText(text);
    }

    public void setImatge(String path) {
        Image imatge = new Image(Objects.requireNonNull(getClass().getResource(path)).toExternalForm());
        img.setImage(imatge);
    }

    private void initMouseEvents() {
        // Click en el ítem → actualizar detalle
        infoPane.setOnMouseClicked(new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent e) {
                Controller c = (Controller) UtilsViews.getController("layout");
                c.actualizarTitol(title.getText());
                c.actualizarImatge(img.getImage());
                c.actualitzarInformacio(info);  // edad del animal
                c.crearRectangle(color);        // color del animal
            }
        });

        // Hover → cambiar color de fondo
        infoPane.setOnMouseEntered(e -> infoPane.setStyle("-fx-background-color:#dae7f3;"));
        infoPane.setOnMouseExited(e -> infoPane.setStyle("-fx-background-color:transparent;"));
    }
}
