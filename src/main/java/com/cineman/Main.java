package com.cineman;

import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

public class Main {
    public static void main(String[] args) throws Exception {
        int port = 8080;
        String portProp = System.getProperty("server.port", System.getenv("PORT"));
        if (portProp != null) {
            try {
                port = Integer.parseInt(portProp);
            } catch (NumberFormatException ignored) {}
        }

        Tomcat tomcat = new Tomcat();
        tomcat.setBaseDir("temp_tomcat");
        tomcat.setPort(port);
        tomcat.getConnector();

        String webappDir = new File("src/main/webapp").getAbsolutePath();
        Context ctx = tomcat.addWebapp("", webappDir);
        ctx.setParentClassLoader(Main.class.getClassLoader());

        File additionWebInfClasses = new File("target/classes");
        if (additionWebInfClasses.exists()) {
            WebResourceRoot resources = new StandardRoot(ctx);
            resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
                    additionWebInfClasses.getAbsolutePath(), "/"));
            ctx.setResources(resources);
        }

        tomcat.start();
        System.out.println("==================================================================");
        System.out.println("  CineMan Cinema Management System (Đề 13 B23DCCN211)");
        System.out.println("  Apache Tomcat Server started at: http://localhost:" + port + "/");
        System.out.println("==================================================================");
        tomcat.getServer().await();
    }
}
