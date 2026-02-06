package com.project;

import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ResourceBundle;

import org.json.JSONArray;
import org.json.JSONObject;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Parent;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.geometry.Pos;

public class Controller implements Initializable {

    String[] titols = {"Domestic","Wild","Aquatic"};

    @FXML
    private ImageView infoImatge;
    @FXML
    private Label titol, info, DBtitle;
    @FXML
    private AnchorPane container;
    @FXML
    public VBox infoVbox, detallesVbox;
    @FXML
    private ChoiceBox<String> choiceBox;

    private JSONArray jsonData;
    private Rectangle rectangle = null;

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        try {
            choiceBox.getItems().addAll(titols);
            choiceBox.setValue(titols[0]);
            setDades(choiceBox.getValue());

            choiceBox.setOnAction((event) -> {
                String selectedTable = choiceBox.getSelectionModel().getSelectedItem();
                setDades(selectedTable);
            });

            cargarItems();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void actualizarTitol(String title){
        titol.setText(title);
    }

    public void actualitzarInformacio(String infoExtra){
        info.setText(infoExtra);
        info.setWrapText(true);
    }

    public void crearRectangle(String color){
        detallesVbox.setAlignment(Pos.CENTER);

        // Todos los animales tienen color, así que no hacemos excepciones
        if (rectangle == null) {
            rectangle = new Rectangle(25, 25);
            detallesVbox.getChildren().add(2, rectangle);
        }
        rectangle.setFill(Color.valueOf(color));
    }

    public void actualizarImatge(Image img) {
        infoImatge.setImage(img);
    }

    private void setDades(String nom) {
        try {
            String jsonArxiu = "/assets/data/" + nom + ".json";
            infoVbox.getChildren().clear();
            URL jsonURL = getClass().getResource(jsonArxiu);
            Path jsonPath = Paths.get(jsonURL.toURI());
            String content = Files.readString(jsonPath);
            jsonData = new JSONArray(content);

            cargarItems();
        } catch (Exception e) {
            System.out.println("Error al cargar el archivo JSON");
            e.printStackTrace();
        }
    }

    private String getInfo(JSONObject item, String tipus) {
        // Para animales, devolvemos color y edad
        switch (tipus) {
            case "Domestic":
            case "Wild":
            case "Aquatic":
                return "Color: " + item.getString("color") + "\nEdad: " + item.getInt("age");
            default:
                return "";
        }
    }

    private String getColor(JSONObject item, String tipus) {
        switch (tipus) {
            case "Domestic":
            case "Wild":
            case "Aquatic":
                return item.getString("color");
            default:
                return null;
        }
    }

    private void cargarItems() {
        try {
            infoVbox.getChildren().clear();
            String tipus = choiceBox.getValue();

            for (int i = 0; i < jsonData.length(); i++) {
                JSONObject item = jsonData.getJSONObject(i);
                String name = item.getString("name");
                String image = item.getString("image");

                URL fxmlURL = getClass().getResource("/assets/views/infoView.fxml");
                FXMLLoader loader = new FXMLLoader(fxmlURL);
                Parent itemTemplate = loader.load();

                ControllerListItem itemController = loader.getController();
                itemController.setTitle(name);
                itemController.setImatge("/assets/data/images/" + image);
                itemController.setInfo(getInfo(item, tipus));

                String color = getColor(item, tipus);
                if (color != null && !color.isEmpty()) {
                    itemController.setColor(color);
                }

                infoVbox.getChildren().add(itemTemplate);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
