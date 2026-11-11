package model;

import java.io.Serializable;

public class StatsMovies1 implements Serializable {
    private static final long serialVersionUID = 1L;

    private Movie1 movie;
    private int totalTicket;
    private int totalRev;

    public StatsMovies1() {
    }

    public StatsMovies1(Movie1 movie, int totalTicket, int totalRev) {
        this.movie = movie;
        this.totalTicket = totalTicket;
        this.totalRev = totalRev;
    }

    public Movie1 getMovie() {
        return movie;
    }

    public void setMovie(Movie1 movie) {
        this.movie = movie;
    }

    public int getTotalTicket() {
        return totalTicket;
    }

    public void setTotalTicket(int totalTicket) {
        this.totalTicket = totalTicket;
    }

    public int getTotalRev() {
        return totalRev;
    }

    public void setTotalRev(int totalRev) {
        this.totalRev = totalRev;
    }
}

