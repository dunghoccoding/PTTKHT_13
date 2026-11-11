package model;

import java.io.Serializable;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class ShowTime1 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Date dateShow;
    private String hoursShow;
    private float priceTicket;
    private Movie1 movie;
    private ScreenRoom1 room;
    private List<Ticket1> dsTicket = new ArrayList<>();

    public ShowTime1() {
    }

    public ShowTime1(int id, Date dateShow, String hoursShow, float priceTicket, Movie1 movie, ScreenRoom1 room) {
        this.id = id;
        this.dateShow = dateShow;
        this.hoursShow = hoursShow;
        this.priceTicket = priceTicket;
        this.movie = movie;
        this.room = room;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Date getDateShow() {
        return dateShow;
    }

    public void setDateShow(Date dateShow) {
        this.dateShow = dateShow;
    }

    public String getHoursShow() {
        return hoursShow;
    }

    public void setHoursShow(String hoursShow) {
        this.hoursShow = hoursShow;
    }

    public float getPriceTicket() {
        return priceTicket;
    }

    public void setPriceTicket(float priceTicket) {
        this.priceTicket = priceTicket;
    }

    public Movie1 getMovie() {
        return movie;
    }

    public void setMovie(Movie1 movie) {
        this.movie = movie;
    }

    public ScreenRoom1 getRoom() {
        return room;
    }

    public void setRoom(ScreenRoom1 room) {
        this.room = room;
    }

    public ScreenRoom1 getScreenRoom() {
        return room;
    }

    public void setScreenRoom(ScreenRoom1 screenRoom) {
        this.room = screenRoom;
    }

    public List<Ticket1> getDsTicket() {
        return dsTicket;
    }

    public void setDsTicket(List<Ticket1> dsTicket) {
        this.dsTicket = dsTicket;
    }
}