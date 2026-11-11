package model;

import java.io.Serializable;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class StatsRevenue implements Serializable {
    private static final long serialVersionUID = 1L;

    private float total;
    private List<Bill1> dsBill = new ArrayList<>();
    private Date startDate;
    private Date endDate;

    public StatsRevenue() {
    }

    public StatsRevenue(float total, List<Bill1> dsBill, Date startDate, Date endDate) {
        this.total = total;
        this.dsBill = dsBill;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public float getTotal() {
        return total;
    }

    public void setTotal(float total) {
        this.total = total;
    }

    public List<Bill1> getDsBill() {
        return dsBill;
    }

    public void setDsBill(List<Bill1> dsBill) {
        this.dsBill = dsBill;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
}

