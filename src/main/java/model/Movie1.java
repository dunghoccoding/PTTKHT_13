package model;

import java.io.Serializable;

public class Movie1 implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String nameMovies;
    private String type;
    private int duration;
    private String cast;
    private String director;
    private String descriptions;

    public Movie1() {
    }

    public Movie1(int id, String nameMovies, String type, int duration, String cast, String director, String descriptions) {
        this.id = id;
        this.nameMovies = nameMovies;
        this.type = type;
        this.duration = duration;
        this.cast = cast;
        this.director = director;
        this.descriptions = descriptions;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNameMovies() {
        return nameMovies;
    }

    public void setNameMovies(String nameMovies) {
        this.nameMovies = nameMovies;
    }

    // Alias for diagram compatibility
    public String getNameMovie() {
        return nameMovies;
    }

    public void setNameMovie(String nameMovie) {
        this.nameMovies = nameMovie;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getCast() {
        return cast;
    }

    public void setCast(String cast) {
        this.cast = cast;
    }

    public String getDirector() {
        return director;
    }

    public void setDirector(String director) {
        this.director = director;
    }

    public String getDescriptions() {
        return descriptions;
    }

    public void setDescriptions(String descriptions) {
        this.descriptions = descriptions;
    }

    // Alias for diagram compatibility
    public String getDescription() {
        return descriptions;
    }

    public void setDescription(String description) {
        this.descriptions = description;
    }

    @Override
    public String toString() {
        return "Movie1{" +
                "id=" + id +
                ", nameMovies='" + nameMovies + '\'' +
                ", type='" + type + '\'' +
                ", duration=" + duration +
                '}';
    }
}

