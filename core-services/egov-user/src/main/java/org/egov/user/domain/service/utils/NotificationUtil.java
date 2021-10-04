package org.egov.user.domain.service.utils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.egov.common.contract.request.RequestInfo;
import org.egov.user.persistence.repository.ServiceRequestRepository;
import org.egov.user.producer.UserSMSProducer;
import org.egov.user.web.contract.SMSRequest;
import org.egov.user.web.contract.ShortenRequest;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import com.jayway.jsonpath.JsonPath;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class NotificationUtil {
	
	private String URL = "url";
	
	@Autowired
	private ServiceRequestRepository serviceRequestRepository;
	
	@Autowired
	private UserSMSProducer producer;
	
	
	@Value("${kafka.topics.notification.sms}")
	private String smsNotifTopic;

	@Value("${notification.sms.enabled}")
	private Boolean isSMSEnabled;
	
	 
	
 
	
	@Value("${egov.localization.host}")
	private String localizationHost;

	@Value("${egov.localization.context.path}")
	private String localizationContextPath;

	@Value("${egov.localization.search.endpoint}")
	private String localizationSearchEndpoint;

	@Value("${egov.localization.statelevel}")
	private Boolean isLocalizationStateLevel;
	
	@Value("${notification.url}")
	private String notificationUrl;
    
    @Value("${egov.mgramseva.ui.path}")
	private String webUiPath;
    
    @Value("${egov.shortener.url}")
	private String shortenerURL;
	
	public static final String NOTIFICATION_LOCALE = "en_IN";
	public static final String MODULE = "mgramseva-ws,mgramseva-common";
	
	/**
	 * Returns the uri for the localization call
	 * 
	 * @param tenantId
	 *            TenantId demand Notification Obj
	 * @return The uri for localization search call
	 */
	public StringBuilder getUri(String tenantId, RequestInfo requestInfo) {

		if (isLocalizationStateLevel)
			tenantId = tenantId.split("\\.")[0];

		String locale = NOTIFICATION_LOCALE;
		if (!StringUtils.isEmpty(requestInfo.getMsgId()) && requestInfo.getMsgId().split("|").length >= 2)
			locale = requestInfo.getMsgId().split("\\|")[1];
		StringBuilder uri = new StringBuilder();
		uri.append(localizationHost).append(localizationContextPath)
				.append(localizationSearchEndpoint).append("?").append("locale=").append(locale)
				.append("&tenantId=").append(tenantId).append("&module=").append(MODULE);

		return uri;
	}
	
	/**
	 * Fetches messages from localization service
	 * 
	 * @param tenantId
	 *            tenantId of the tradeLicense
	 * @param requestInfo
	 *            The requestInfo of the request
	 * @return Localization messages for the module
	 */
	public String getLocalizationMessages(String tenantId, RequestInfo requestInfo) {
		@SuppressWarnings("rawtypes")
		LinkedHashMap responseMap = (LinkedHashMap) serviceRequestRepository.fetchResult(getUri(tenantId, requestInfo),
				requestInfo);
		return new JSONObject(responseMap).toString();
	}
	 
	
	/**
	 * Extracts message for the specific code
	 * 
	 * @param notificationCode The code for which message is required
	 * @param localizationMessage The localization messages
	 * @return message for the specific code
	 */
	public String getMessageTemplate(String notificationCode, String localizationMessage) {
		String path = "$..messages[?(@.code==\"{}\")].message";
		path = path.replace("{}", notificationCode);
		String message = null;
		try {
			ArrayList<String> messageObj = (ArrayList<String>) JsonPath.parse(localizationMessage).read(path);
			if(messageObj != null && messageObj.size() > 0) {
				message = messageObj.get(0);
			}
		} catch (Exception e) {
			log.warn("Fetching from localization failed", e);
		}
		return message;
	}
	
	
	/**
	 * Send the SMSRequest on the SMSNotification kafka topic
	 * @param smsRequestList The list of SMSRequest to be sent
	 */
	public void sendSMS(List<SMSRequest> smsRequestList) {
		if (isSMSEnabled) {
			if (CollectionUtils.isEmpty(smsRequestList)) {
				log.info("Messages from localization couldn't be fetched!");
				return;
			}
			for (SMSRequest smsRequest : smsRequestList) {
				producer.push(smsNotifTopic, smsRequest);
				log.info("Messages: " + smsRequest.getMessage());
			}
		}
	}
	
	 
	public String getShortnerURL( ) {
		String	actualURL=notificationUrl+webUiPath;
		ShortenRequest request=new ShortenRequest();
		request.setUrl(actualURL);
		String url = notificationUrl + shortenerURL;
		
		Object response = serviceRequestRepository.getShorteningURL(new StringBuilder(url), request);
		return response.toString();
	}
	 
	   
	 

}
