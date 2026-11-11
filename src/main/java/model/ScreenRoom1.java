package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ScreenRoom1 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String nameScreen;
    private int seatNums;
    private String description;
    private Cinema1 cinema;
    private List<Seat1> dsSeat = new ArrayList<>();
    private List<ShowTime1> dsShowtime = new ArrayList<>();

    public ScreenRoom1() {
    }

    public ScreenRoom1(int id, String nameScreen, int seatNums, String description, Cinema1 cinema) {
        this.id = id;
        this.nameScreen = nameScreen;
        this.seatNums = seatNums;
        this.description = description;
        this.cinema = cinema;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNameScreen() {
        return nameScreen;
    }

    public void setNameScreen(String nameScreen) {
        this.nameScreen = nameScreen;
    }

    public int getSeatNums() {
        return seatNums;
    }

    public void setSeatNums(int seatNums) {
        this.seatNums = seatNums;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Cinema1 getCinema() {
        return cinema;
    }

    public void setCinema(Cinema1 cinema) {
        this.cinema = cinema;
    }

    public List<Seat1> getDsSeat() {
        return dsSeat;
    }

    public void setDsSeat(List<Seat1> dsSeat) {
        this.dsSeat = dsSeat;
    }

    public List<ShowTime1> getDsShowtime() {
        return dsShowtime;
    }

    public void setDsShowtime(List<ShowTime1> dsShowtime) {
        this.dsShowtime = dsShowtime;
    }
}

