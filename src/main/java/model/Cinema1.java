package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Cinema1 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String nameCine;
    private String address;
    private String description;
    private int column;
    private List<ScreenRoom1> dsScreenRoom = new ArrayList<>();

    public Cinema1() {
    }

    public Cinema1(int id, String nameCine, String address, String description, int column) {
        this.id = id;
        this.nameCine = nameCine;
        this.address = address;
        this.description = description;
        this.column = column;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNameCine() {
        return nameCine;
    }

    public void setNameCine(String nameCine) {
        this.nameCine = nameCine;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getColumn() {
        return column;
    }

    public void setColumn(int column) {
        this.column = column;
    }

    public List<ScreenRoom1> getDsScreenRoom() {
        return dsScreenRoom;
    }

    public void setDsScreenRoom(List<ScreenRoom1> dsScreenRoom) {
        this.dsScreenRoom = dsScreenRoom;
    }
}

