package javacode.controlador;

import java.sql.Connection;
import java.sql.DriverManager;
import javax.swing.JOptionPane;
import javax.swing.JOptionPane;

           
public class Conexion {
    Connection connection = null;
    String urlDB = "";

    public Conexion() {
        try{
            urlDB = JOptionPane.showInputDialog(null, "Ingrese la ruta de la base de datos");
            Class.forName("org.sqlite.JDBC");
            connection = DriverManager.getConnection(urlDB);
            
             JOptionPane.showMessageDialog(null, "Conexión exitosa");
            
        } catch (Exception e){
            JOptionPane.showMessageDialog(null, "Error de conexión\nBase de datos no encontrada o desabilitada");
        }
    }
}
