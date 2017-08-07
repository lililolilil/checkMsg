package com.suyeon.checkMsg;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.PatternSyntaxException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;

/**
 * Handles requests for the application home page.
 */
@Controller
@RequestMapping("/checkMsg")
@EnableWebMvc
public class CheckMsgController {
	
	private static final Logger logger = LoggerFactory.getLogger(CheckMsgController.class);

	@Autowired
	private CheckMsgService checkMsgService;  
	
	@RequestMapping(value = "/getFilelist", method = RequestMethod.POST, produces="application/json;charset=UTF-8")
	@ResponseBody
	public Map<String,Object> getFilelist(@RequestBody String form_data, Model model){
		logger.info("getFilelist");

		HashMap<String, Object> resultMap = new HashMap<>();
		Map<String,String> fileMap = new HashMap<>();  

		try {
		
			JSONObject jsonObj = new JSONObject(form_data);  
			String baseDir = jsonObj.getString("baseDir"); 
			String messagefileDir = jsonObj.getString("messagefileDir"); 
			logger.info(baseDir+messagefileDir);	
			fileMap = checkMsgService.getFilePathtoMap(baseDir+messagefileDir,"properties"); 
		}catch (FileNotFoundException e){
			resultMap.put("err", " 파일경로를 다시 확인해 주세요."); 
		}catch (Exception e) {
			e.printStackTrace();
			resultMap.put("err", "시스템 에 문제가 생겼습니다. 확인 후 다시 시도해 주세요."); 
		}
		resultMap.put("messagefile", fileMap); 
		// 체크 해야 하는 메시지 
		return resultMap;
	}
	
	@RequestMapping(value = "/getAllMessage", method = RequestMethod.GET)
	public String getAllMessage(Model model) {
		logger.info("getAllMessage");
		model.addAttribute("title", "전체메시지보기"); 
		model.addAttribute("menu", "getAllMessage"); 
		return "check/getAllMessage";
	}
	
	@RequestMapping(value = "/getAllMessage", method = RequestMethod.POST, produces="application/json;charset=UTF-8")
	@ResponseBody
	public Map<String,Object> getAllMessage(@RequestBody String form_data, Model model){
		logger.info("getAllMessage");

		HashMap<String, Object> resultMap = new HashMap<>();

		HashMap<String, Object> allMessage = new HashMap<>();
		HashMap<String, Object> message= new HashMap<>();
		
		try {
			JSONObject jsonObj = new JSONObject(form_data);  
			JSONArray messagefileList = jsonObj.getJSONArray("messagefileList"); 
			for(int i = 0 ; i < messagefileList.length(); i++){
				JSONObject fileinfo = messagefileList.getJSONObject(i);
				String fileName = fileinfo.getString("fileName"); 
				Map<String, String>messageMap = checkMsgService.getMessages(fileinfo.getString("filePath"));
				Iterator<String> itr = messageMap.keySet().iterator();  
				while(itr.hasNext()){
					String code = itr.next();  
					if(message.keySet().contains(code)){
						ArrayList<Object> valuelist = (ArrayList<Object>) message.get(code); 
						Map<String,String> value = new HashMap<>(); 
						value.put(fileName, messageMap.get(code)); 
						valuelist.add(value); 
						message.replace(code, valuelist); 
					}else{
						ArrayList<Object> valuelist = new ArrayList<>(); 
						Map<String,String> value = new HashMap<>(); 
						value.put(fileName, messageMap.get(code)); 
						valuelist.add(value); 
						message.put(code, valuelist); 
					}	
				}
				
			}
			resultMap.put("message", message); 
		} catch (FileNotFoundException e) {
			resultMap.put("err","메시지 파일을 찾을 수 없습니다. 경로를 확인하세요 "); 
		} catch (Exception e) {
			resultMap.put("err","파라미터 오류 "); 
		}
		Map<Object, Object> SortedMessage = checkMsgService.sortByKey(message, true); 
		// 체크 해야 하는 메시지 
		resultMap.put("result",SortedMessage); 
		return resultMap;
	}
	
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/editMsgfile", method = RequestMethod.POST, produces="application/json;charset=UTF-8")
	@ResponseBody
	public Map<String,Object> editMsgfile(@RequestBody String param, Model model){
		logger.info("getAllMessage");

		HashMap<String, Object> resultMap = new HashMap<>();
		ArrayList<String> deletelist = new ArrayList<>();
		HashMap<String, Object> updateMap = new HashMap<>(); 
		HashMap<String, String> newMsgMap =  new HashMap<>(); 

		try {
			JSONObject jsonObj = new JSONObject(param);  
			JSONArray delete = jsonObj.getJSONArray("deletemsg"); 
			JSONArray update = jsonObj.getJSONArray("updatemsg");
			String folderPath = jsonObj.getString("folderPath");
			JSONArray files = jsonObj.getJSONArray("files"); // 파일명이 담긴 list 
			for(int i=0; i < files.length(); i++){
				updateMap.put(files.getString(i), newMsgMap); 
			}
			for(int i=0; i < delete.length(); i++){
				deletelist.add(delete.getString(i).replaceAll("_", ".")); 
			}
			for(Object obj: deletelist){
				System.out.println("deleteMsg");
				System.out.println(obj.toString());
			}
			
			//update해야 하는 메시지 파일별로 분류 
			for(int j=0; j < update.length(); j++){
				JSONObject message = update.getJSONObject(j);
				String code = message.getString("code").replaceAll("_", "."); 
				String fileName= message.getString("fileName");
				String valueString= message.getString("valueString");
				if(updateMap.containsKey(fileName)){
					newMsgMap = (HashMap<String, String>) updateMap.get(fileName); 
					newMsgMap.put(code, valueString); 
				}else{
					newMsgMap.put(code, valueString);
					updateMap.put(fileName, newMsgMap); 
				}
			}
			ArrayList<String> result = new ArrayList<>(); 

			Iterator<String> itr = updateMap.keySet().iterator();  
			while(itr.hasNext()){
				String fileName = itr.next();
				String info = checkMsgService.createfile((HashMap<String,String>)updateMap.get(fileName), deletelist, folderPath, fileName); 
				logger.info(info+ "파일이 생성되었습니다.");
				result.add(info+"파일이 생성되었습니다.");  
			}
			resultMap.put("result", result); 
			
		}catch (JSONException e) {
			e.printStackTrace();
			resultMap.put("err","파라미터 오류 "); 

		}catch (Exception e) {
			e.printStackTrace();
			resultMap.put("err","파라미터 오류 "); 

		}
		resultMap.put("delete", deletelist); 
		resultMap.put("update", updateMap);  
		// 체크 해야 하는 메시지 
		return resultMap;
	}
	
	
	/**
	 * Simply selects the home view to render by returning its name.
	 */
	@RequestMapping(value = "/syncMessage", method = RequestMethod.GET)
	public String syncMessage_form(Model model) {
		logger.info("syncMessageForm");
		model.addAttribute("title", "syncMessageForm"); 
		model.addAttribute("menu", "syncMessage"); 
		return "check/syncMessage";
	}
	
	@RequestMapping(value = "/syncMessage", method = RequestMethod.POST, produces="application/json;charset=UTF-8")
	@ResponseBody
	public Map<String,Object> syncMessageCheck(@RequestBody String syncInfo, Model model){
		logger.info("syncMessageFile");

		HashMap<String, Object> resultMap = new HashMap<>();
		HashMap<String, Object> allMessage = new HashMap<>();
		try {
			JSONObject jsonObj = new JSONObject(syncInfo);  
			String baseDir = jsonObj.getString("baseDir"); 
			String messagefileDir = jsonObj.getString("messagefileDir"); 
			allMessage = checkMsgService.getAllMessage(baseDir+messagefileDir);
			
		} catch (FileNotFoundException e) {
			resultMap.put("err","메시지 파일을 찾을 수 없습니다. 경로를 확인하세요 "); 
		} catch (Exception e) {
			resultMap.put("err","파라미터 오류 "); 
		}
		// 체크 해야 하는 메시지 
		resultMap.put("result",checkMsgService.sortByKey(checkMsgService.messageSyncCheck(allMessage),true)); 
		return resultMap;
	}
	
	
	@RequestMapping(value = "/usingMessage", method = RequestMethod.GET)
	public String usingMessage_form(Model model) {
		logger.info("usingMessageForm");
		model.addAttribute("title", "usingMessageForm"); 
		model.addAttribute("menu", "usingMessage"); 

		return "check/usingMessage";
	}
	@RequestMapping(value = "/usingMessage", method = RequestMethod.POST, produces="application/json;charset=UTF-8")
	@SuppressWarnings("unchecked")
	@ResponseBody
	public Map<String,Object> usingMessageCheck(@RequestBody String form_data, Model model) throws JsonParseException, JsonMappingException, IOException {
		logger.info("find using message code~! ");
		model.addAttribute("title","usingMessage 결과"); 
		model.addAttribute("menu", "syncMessage"); 
		HashMap<String, Object> reqMap = new HashMap<>();
		Map<String, Object> resultMap = new HashMap<>();

		try{
			JSONObject jsonObj = new JSONObject(form_data);  
			String baseDir = jsonObj.getString("baseDir"); 
			String javafileDir = jsonObj.getString("javafileDir"); 
			String viewfileDir = jsonObj.getString("viewfileDir"); 
			String standardMsgfileDir = jsonObj.getString("standardMsgfileDir"); 
			List<Object> javaPatterns = jsonObj.getJSONArray("javaPatterns").toList();  
			List<Object> viewPatterns = jsonObj.getJSONArray("viewPatterns").toList();
			
			reqMap.put("baseDir", baseDir); 
			reqMap.put("javafileDir",baseDir+javafileDir); 
			reqMap.put("viewfileDir",baseDir+viewfileDir); 
			reqMap.put("standardMsgfileDir",standardMsgfileDir); 
			reqMap.put("javaPatterns",javaPatterns); 
			reqMap.put("viewPatterns",viewPatterns); 
			checkMsgService.printMap("요청 파라미터", reqMap);
			
		}catch(JSONException e){
			e.printStackTrace();
		}catch(Exception e){
			resultMap.put("err", "요청 파라미터를 읽어드리던 중 오류가 발생했습니다."); 
		}
		
		try{
			HashMap<String, String> standardMsg= checkMsgService.getMessages(reqMap.get("standardMsgfileDir").toString()); 
			ArrayList<String> javafilePath = checkMsgService.getFilePath(reqMap.get("javafileDir").toString()); 
			HashMap<String, String> javaUsingMsg = checkMsgService.extractionMessage(reqMap.get("baseDir").toString(), javafilePath, (List<String>) reqMap.get("javaPatterns")); 
			ArrayList<String> viewfilePath = checkMsgService.getFilePath(reqMap.get("viewfileDir").toString(),".jsp"); 
			HashMap<String, String> viewUsingMsg = checkMsgService.extractionMessage(reqMap.get("baseDir").toString(), viewfilePath, (List<String>) reqMap.get("viewPatterns")); 
			HashMap<String, String> haveToAdd = new HashMap<>(); 
			//java 에서 쓰고 있는데 standardMsg에 없는 것... 
			haveToAdd.putAll(checkMsgService.compareTwoHmapKey(javaUsingMsg, standardMsg));
			haveToAdd.putAll(checkMsgService.compareTwoHmapKey(viewUsingMsg, standardMsg));
			Map<Object, Object> mappedMsg = new HashMap<>();
			mappedMsg = checkMsgService.mappingTwoHmap(standardMsg, javaUsingMsg, mappedMsg); 
			mappedMsg = checkMsgService.mappingTwoHmap(standardMsg, viewUsingMsg, mappedMsg);
			resultMap.put("haveToAdd", haveToAdd); 
			resultMap.put("mappedMsg", mappedMsg); 
			
			//jsp에서 쓰고 있는데 standardMsg에 없는것 
		}catch(FileNotFoundException e) {
			resultMap.put("err","standardMsg 파일을 찾을 수 없습니다. 경로: "+ reqMap.get("standardMsgfileDir").toString()); 
		}catch(PatternSyntaxException e){
			resultMap.put("err", "잘못 된 정규식입니다. 정규식 문법을 확인해 주세요.. " ); 
		}catch(Exception e){
			resultMap.put("err", "검사 중 에러가 발생했습니다." ); 
		}
		
		// 체크 해야 하는 메시지 
		//resultMap.put("entireMsg", entireMsg); 
		return resultMap;
	}
}
