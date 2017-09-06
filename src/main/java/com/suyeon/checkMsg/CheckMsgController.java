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
			//String baseDir = jsonObj.getString("baseDir"); 
			String messagefileDir = jsonObj.getString("messagefileDir"); 
			logger.info(messagefileDir);	
			fileMap = checkMsgService.getFilePathtoMap(messagefileDir,".properties"); 
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
	
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/getAllMessage", method = RequestMethod.POST, produces="application/json;charset=UTF-8")
	@ResponseBody
	public Map<String,Object> getAllMessage(@RequestBody String form_data, Model model){
		logger.info("getAllMessage");

		HashMap<String, Object> resultMap = new HashMap<>();

		HashMap<String, Object> message= new HashMap<>();
		
		try {
			JSONObject jsonObj = new JSONObject(form_data);  
			JSONArray messagefileList = jsonObj.getJSONArray("messagefileList"); 
			ArrayList<String> fileNames = new ArrayList<>();
			for(int i = 0 ;  i<messagefileList.length(); i++){
				fileNames.add(messagefileList.getJSONObject(i).getString("fileName"));
			}
			
			for(int i = 0 ; i < messagefileList.length(); i++){
				JSONObject fileinfo = messagefileList.getJSONObject(i);
				String fileName = fileinfo.getString("fileName");
				Map<String, String>messageMap = checkMsgService.getMessages(fileinfo.getString("filePath"));
				Iterator<String> itr = messageMap.keySet().iterator();  

				while(itr.hasNext()){
					HashMap<String, String> valueMap = new HashMap<>(); 
					String code = itr.next(); 
					if(!message.keySet().contains(code)){
						for(int j = 0; j<fileNames.size(); j++){
							valueMap.put(fileNames.get(j), ""); 
						}
						message.put(code, valueMap); 
					}
					valueMap = (HashMap<String, String>) message.get(code); 
					valueMap.replace(fileName, messageMap.get(code)); 
					message.put(code, valueMap); 
					checkMsgService.printMap(code, (Map) message.get(code));  
				}
				
			}
		} catch (FileNotFoundException e) {
			resultMap.put("err","메시지 파일을 찾을 수 없습니다. 경로를 확인하세요 "); 
		} catch (Exception e) {
			e.printStackTrace();
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
		List<Object> deletelist = new ArrayList<>();
		HashMap<String, Object> updateMap = new HashMap<>(); 

		try {
			JSONObject jsonObj = new JSONObject(param);  
			JSONArray deletemsg = jsonObj.getJSONArray("deletemsg"); 
			JSONArray update = jsonObj.getJSONArray("updatemsg");
			String folderPath = jsonObj.getString("folderPath");
			JSONArray files = jsonObj.getJSONArray("files"); // 파일명이 담긴 list

			for(int i=0; i < files.length(); i++){
				HashMap<String, String> inerMap = new HashMap<>(); 
				updateMap.put(files.getString(i), inerMap); 
			}
			
			deletelist = checkMsgService.toList(deletemsg); 
			
			//update해야 하는 메시지 파일별로 분류 
			for(int j=0; j < update.length(); j++){
				JSONObject message = update.getJSONObject(j);
				String code = message.getString("code").replaceAll("_", "."); 
				String fileName= message.getString("fileName");
				String valueString= message.getString("valueString");
				System.out.println(code +  "/ " + fileName +  "/ " +  valueString );
				if(updateMap.containsKey(fileName)){
					HashMap<String,String> inerMap = (HashMap<String, String>) updateMap.get(fileName); 
					inerMap.put(code, valueString); 
					/*
					 // 디버그용 
					System.out.println("msgmap size: "  + inerMap.size());
					System.out.println("put >>>  " + code  + " / " + valueString);
					Iterator<String> iner = inerMap.keySet().iterator(); 
					while(iner.hasNext()){
						String inercode = iner.next(); 
						System.out.println(inercode + inerMap.get(inercode )); 
					}*/
					updateMap.replace(fileName, inerMap); 
				}else{
					throw new FileNotFoundException(" 수정할 파일 대상이 아닙니다. "); 
				}
			}
			ArrayList<String> result = new ArrayList<>(); 
			
			/*Iterator<String> itr = updateMap.keySet().iterator();  
			//디버깅용 
			while(itr.hasNext()){
				String fileNm = itr.next();
				HashMap<String, String> updateCodeMap = (HashMap<String,String>)updateMap.get(fileNm); 
				Iterator<String> itr2 = updateCodeMap.keySet().iterator();  
				System.out.println("파일명: " + fileNm);
				while(itr2.hasNext()){
					String code = itr2.next(); 
					System.out.println(code + " = " + updateCodeMap.get(code).toString());
				}
			}
			*/
			
			Iterator<String> itr = updateMap.keySet().iterator();  

			while(itr.hasNext()){
				String fileNm = itr.next();
				String info = checkMsgService.createfile((HashMap<String,Object>)updateMap.get(fileNm), deletelist, folderPath, fileNm); 
				logger.info("\n"+info);
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
	
	@SuppressWarnings("unchecked")
	@RequestMapping(value = "/createMsgfile", method = RequestMethod.POST, produces="application/json;charset=UTF-8")
	@ResponseBody
	public Map<String,Object> createMsgfile(@RequestBody String param, Model model){
		logger.info("getAllMsg - createMsgfile");

		HashMap<String, Object> resultMap = new HashMap<>();
		List<Object> deletelist = new ArrayList<>(); 

		try {
			JSONObject jsonObj = new JSONObject(param);  
			String folderPath = jsonObj.getString("folderPath");
			JSONObject fileMessageMap = jsonObj.getJSONObject("fileMessageMap"); //{file: {code:val,code:val.....}} 
			JSONArray fileList = jsonObj.getJSONArray("fileList"); 
			JSONArray deletemsg = jsonObj.getJSONArray("deletemsg"); 
			String standardFile = jsonObj.getString("standardFile"); // messagefile 경로 
			
			deletelist = checkMsgService.toList(deletemsg); 
			
			for(int i=0; i < fileList.length(); i++){
				String fileName = fileList.getString(i);  
				String info = ""; 
				Map<String, Object> codeAndVal  = checkMsgService.jsonToMap((JSONObject)fileMessageMap.get(fileName)); 
				if(fileName.equals(standardFile)){
					info = checkMsgService.createfile((HashMap<String,Object>)codeAndVal, deletelist, folderPath, fileName); 
				}else{
					info = checkMsgService.createfile((HashMap<String,Object>)codeAndVal.get(fileName), deletelist, folderPath, standardFile, fileName); 
				}; 
				
				resultMap.put("info"+i, info); 
			}
			
			
		}catch (JSONException e) {
			e.printStackTrace();
			resultMap.put("err","파라미터 오류 "); 

		}catch (Exception e) {
			e.printStackTrace();
			resultMap.put("err","파라미터 오류 "); 

		}

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
			JSONArray msgfileList = jsonObj.getJSONArray("messagefileList"); 
			for(int i = 0; i< msgfileList.length() ; i++ ){
				JSONObject msgFileInfo = msgfileList.getJSONObject(i);
				allMessage.put(msgFileInfo.getString("fileName"), checkMsgService.getMessages(msgFileInfo.getString("filePath")));  
			}
			
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
	@ResponseBody
	public Map<String,Object> usingMessageCheck(@RequestBody String form_data, Model model) throws JsonParseException, JsonMappingException, IOException {
		logger.info("find using message code~! ");
		model.addAttribute("title","usingMessage 결과"); 
		model.addAttribute("menu", "syncMessage"); 
		HashMap<String, Object> reqMap = new HashMap<>();
		Map<String, Object> resultMap = new HashMap<>();

		try{
			JSONObject jsonObj = new JSONObject(form_data);  
			//String baseDir = jsonObj.getString("baseDir"); 
			List<Object> javafileDirs = jsonObj.getJSONArray("javafileDirs").toList(); 
			List<Object> viewfileDirs = jsonObj.getJSONArray("viewfileDirs").toList(); 
			String standardMsgfileDir = jsonObj.getString("standardMsgfileDir"); 
			List<Object> javaPatterns = jsonObj.getJSONArray("javaPatterns").toList();  
			List<Object> viewPatterns = jsonObj.getJSONArray("viewPatterns").toList();
			HashMap<String, String> standardMsg= checkMsgService.getMessages(standardMsgfileDir.replaceAll("\\\\", "/")); 
			ArrayList<String> javafilePath = new ArrayList<>(); 
			ArrayList<String> viewfilePath = new ArrayList<>(); 
			for(Object obj : javafileDirs){
				String filepath = (String)obj; 
				if(filepath.length()!=0){
					javafilePath.addAll(checkMsgService.getFilePath(filepath,".java")); 
				}
			}
			for(Object obj: viewfileDirs){
				String filepath = (String)obj; 
				if(filepath.length()!=0){
					viewfilePath.addAll(checkMsgService.getFilePath(filepath,".jsp")); 
				}
			}
			
			HashMap<String, String> javaUsingMsg = checkMsgService.extractionMessage(javafilePath, javaPatterns); 
			HashMap<String, String> viewUsingMsg = checkMsgService.extractionMessage(viewfilePath, viewPatterns); 
			HashMap<String, String> haveToAdd = new HashMap<>(); 
			haveToAdd.putAll(checkMsgService.compareTwoHmapKey(javaUsingMsg, standardMsg));
			haveToAdd.putAll(checkMsgService.compareTwoHmapKey(viewUsingMsg, standardMsg));
			Map<Object, Object> mappedMsg = new HashMap<>();
			mappedMsg = checkMsgService.mappingTwoHmap(standardMsg, javaUsingMsg, mappedMsg); 
			mappedMsg = checkMsgService.mappingTwoHmap(standardMsg, viewUsingMsg, mappedMsg);
			resultMap.put("haveToAdd", haveToAdd); 
			resultMap.put("mappedMsg", mappedMsg);
			
		}catch(JSONException e){
			e.printStackTrace();
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
