package model;

import java.io.Serializable;

public class Ticket1 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private float priceTicket;
    private String status;
    private Seat1 seat;
    private ShowTime1 showtime;
    private Bill1 bill;

    public Ticket1() {
    }

    public Ticket1(int id, float priceTicket, String status, Seat1 seat, ShowTime1 showtime, Bill1 bill) {
        this.id = id;
        this.priceTicket = priceTicket;
        this.status = status;
        this.seat = seat;
        this.showtime = showtime;
        this.bill = bill;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public float getPriceTicket() {
        return priceTicket;
    }

    public void setPriceTicket(float priceTicket) {
        this.priceTicket = priceTicket;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Seat1 getSeat() {
        return seat;
    }

    public void setSeat(Seat1 seat) {
        this.seat = seat;
    }

    public ShowTime1 getShowtime() {
        return showtime;
    }

    public void setShowtime(ShowTime1 showtime) {
        this.showtime = showtime;
    }

    public Bill1 getBill() {
        return bill;
    }

    public void setBill(Bill1 bill) {
        this.bill = bill;
    }
}

