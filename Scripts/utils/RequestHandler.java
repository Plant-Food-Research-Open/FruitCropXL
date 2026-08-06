

// ##############################################//
// 	Imports
// ##############################################//
import java.io.*;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.StringTokenizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;
import java.util.Arrays;
import java.lang.Math;

import com.fasterxml.jackson.databind.JsonNode;
import org.apache.commons.math3.distribution.*;
import de.grogra.gpuflux.tracer.FluxLightModelTracer.MeasureMode;
import de.grogra.graph.impl.GraphManager;
import de.grogra.graph.impl.Edge;
import de.grogra.graph.Graph;
import de.grogra.imp.IMPWorkbench;
import de.grogra.imp3d.View3D;
import de.grogra.persistence.Transaction;
import de.grogra.pf.ui.Context;
import de.grogra.pf.ui.util.LockProtectedCommand;
import de.grogra.pf.ui.JobManager;
import de.grogra.pf.ui.Command;
import de.grogra.pf.registry.Item;
import de.grogra.pf.registry.Registry;
import de.grogra.pf.ui.Workbench;
import de.grogra.pf.ui.JobManager;

import de.grogra.util.Lock;
import de.grogra.util.Utils;


//import dhs platform packages
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.SAXException;

/**
 * import cache.dhs.*;
 * import cache.dhs.ModelInterface;
 * import cache.dhs.RunStepArgs;
 * import cache.dhs.Value;
 * import cache.dhs.Reference;
 * import cache.dhs.Metadata;
 * import cache.dhs.Cache;
 * import cache.dhs.CacheResult;
 */


/**
 * Stores the arguments from the DHS simulation request file.
 */
public class RequestHandler {
	public static String request_oid;
	public static String hourly_results;
	public static String daily_results;
	private static String FILE_NAME_MODEL_OPTIONS;

	public static void init(String xmlFilePath) {
		try {
			// Output tables
			Element output_info = getxml_node(xmlFilePath, "simulation_instance/request");
			Element hourly_elem = getxml_node(xmlFilePath, "simulation_instance/execution/outputset/instance[@type='hourly-output']");
			Element daily_elem = getxml_node(xmlFilePath, "simulation_instance/execution/outputset/instance[@type='daily-output']");

			RequestHandler.request_oid = output_info.getAttribute("oid");
			RequestHandler.hourly_results = hourly_elem.getAttribute("oid");
			RequestHandler.daily_results = daily_elem.getAttribute("oid");

			// Parametersets
            Element scenario                = getxml_node(xmlFilePath,"simulation_instance/execution/parameterset/instance[@class_oid='1.3.6.1.4.1.61881.1.1.1.8.1.4.1.1']");
            Element plant_parameters_elem   = getxml_node(xmlFilePath,"simulation_instance/execution/parameterset/instance[@class_oid='1.3.6.1.4.1.61881.1.1.1.8.1.4.5.1']");
            Element initial_conditions_elem = getxml_node(xmlFilePath,"simulation_instance/execution/parameterset/instance[@class_oid='1.3.6.1.4.1.61881.1.1.1.8.1.4.6.1']");

            if (scenario != null) {
                   String scenarioName = scenario.getAttribute("name");
                   System.out.println("scenarioName: " + scenarioName);
                   FILE_NAME_MODEL_OPTIONS = "model.options." + scenarioName + ".json";
               }
           } catch (Exception e) {
              System.out.println("Exception initialising RequestArgs");
               e.printStackTrace();
               }
 
        }



	private static Element getxml_node(String xml_file, String xpath_query) throws SAXException, IOException, ParserConfigurationException, XPathExpressionException {
		Element xml_result;

		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document document = db.parse(new FileInputStream(new File(xml_file)));

		XPathFactory xpf = XPathFactory.newInstance();
		XPath xpath = xpf.newXPath();
		xml_result = (Element) xpath.evaluate(xpath_query, document, XPathConstants.NODE);
		if (xml_result == null) System.out.println("request element not found: " + xpath_query);

		return xml_result;
	}
}

