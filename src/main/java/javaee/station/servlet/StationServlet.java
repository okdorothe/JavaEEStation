package javaee.station.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import javaee.station.Station;
import javaee.station.dao.StationDao;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import com.google.gson.Gson; // Assurez-vous d'avoir Gson dans votre classpath

public class StationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public StationServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String realPath = getServletContext().getRealPath("/WEB-INF/PrixCarburants_annuel_2024.xml"); // Chemin du fichier XML à ajuster
        StationDao stationDao = new StationDao();
        List<Station> stations = stationDao.getAllStations(realPath); // Supposons que cette méthode renvoie toutes les stations depuis le fichier XML

        Set<String> allServices = new HashSet<>();
        for (Station station : stations) {
            allServices.addAll(station.getServices()); // Supposons que getServices() renvoie une liste de services pour chaque station
        }

        // Conversion de la liste des stations en format JSON pour utilisation dans le JSP/JavaScript
        String stationsJson = new Gson().toJson(stations);

        // Passage des données au JSP
        request.setAttribute("stationsJson", stationsJson);
        request.setAttribute("allServices", allServices);

        // Redirection vers le JSP
        request.getRequestDispatcher("/stationMap.jsp").forward(request, response);
    }
}
