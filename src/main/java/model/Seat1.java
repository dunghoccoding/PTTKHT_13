package model;

import java.io.Serializable;

public class Seat1 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int numSeats;
    private String seatCode;
    private String typeSeat;
    private ScreenRoom1 screenRoom;

    public Seat1() {
    }

    public Seat1(int id, int numSeats, String seatCode, String typeSeat, ScreenRoom1 screenRoom) {
        this.id = id;
        this.numSeats = numSeats;
        this.seatCode = seatCode;
        this.typeSeat = typeSeat;
        this.screenRoom = screenRoom;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getNumSeats() {
        return numSeats;
    }

    public void setNumSeats(int numSeats) {
        this.numSeats = numSeats;
    }

    public String getSeatCode() {
        return seatCode;
    }

    public void setSeatCode(String seatCode) {
        this.seatCode = seatCode;
    }

    public String getTypeSeat() {
        return typeSeat;
    }

    public void setTypeSeat(String typeSeat) {
        this.typeSeat = typeSeat;
    }

    public ScreenRoom1 getScreenRoom() {
        return screenRoom;
    }

    public void setScreenRoom(ScreenRoom1 screenRoom) {
        this.screenRoom = screenRoom;
    }
}

