import { $ } from '@wdio/globals'
import {addStep,addAttachment} from '@wdio/allure-reporter';


const dotenv  = require('dotenv');


dotenv.config();

/**
 * sub page containing specific selectors and methods for a specific page
 */
class LoginPage {

  
    /**
     * define selectors using getter methods
     */
    // public get inputUsername () {
    //     return $('#username');
    // }

    // public get inputPassword () {
    //     return $('#password');
    // }
      
    public get btnLogin () {
        return $('//android.widget.Button[@content-desc="Login"]');
    }

    public get btnSetting () {
        return $('//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup/android.widget.Button[1]');
    }

    public get btnApply () {
        return $('//android.widget.Button[@content-desc="Apply"]');
    }

    public get accountTxtBox () {
        return $('//android.widget.EditText');
    }

    public get btnContinue () {
        return $('//android.widget.Button[@text="Continue"]');
    }

    public get emailText () {
        return $('//android.widget.EditText[@resource-id="email-form-item"]');
    }

    public get passwordText () {
        return $('//android.widget.EditText[@resource-id="password-form-item"]');
    }

    public get btnAccLogin () {
        return $('//android.widget.Button[@text="Login"]');
    }

    /**
     * a method to encapsule automation code to interact with the page
     * e.g. to login using username and password
     */
    public async login () {
        try{
        addStep('Application Running Start');
        // await this.inputUsername.setValue(username);
        // await this.inputPassword.setValue(password);
        await this.btnSetting.click();
        addStep('Successfully clicked Login Button');
        
        // const googleAccount = await $('android=new UiSelector().textContains("nithin.murugesan@alvaria.com")');
        // await googleAccount.waitForDisplayed({timeout:10000});
        // await googleAccount.click();
        // await driver.switchContext('com.aspect.wfxmobile');
        // const accountOption = await $('android=new UiSelector().textContains("Continue as")');
        // await accountOption.waitForExist({timeout:5000});
        // await accountOption.click();

        // const condirmgoogleSignin = await $('android=new UiSelector().textContains("Yes")');
        // await condirmgoogleSignin.waitForExist({timeout:5000});
        // await condirmgoogleSignin.click();
        // await driver.pause(10000);
        const account_val = process.env.Account_Val;
         const email = process.env.Email;
           const password = process.env.Password;
         const condirmgoogleSignin = await $('android=new UiSelector().text("Swordfish")');
        await condirmgoogleSignin.waitForExist({timeout:5000});
        await condirmgoogleSignin.click();
         addStep('Successfully logged in google sign in');
        await this.btnApply.click();
         addStep('Successfully Clicked on Apply button');
        await this.btnLogin.click();  
        addStep('Successfully Clicked on Login button');
         await driver.pause(5000);
        await this.accountTxtBox.setValue(account_val!);
        await this.btnContinue.click(); 
        addStep('Successfully Clicked on Continue button');
        await this.emailText.setValue(email!); 
        await this.passwordText.setValue(password!);  
        addStep('Successfully Enter email and password ashish.prasad@aspect.com and Sadsheep66$$');
        await this.btnAccLogin.click();  
        addStep('Successfully Clicked on Account  Login button');
        await driver.pause(10000);
        }
        catch(error){
            addStep('Login failed',{status:'falied'});
            addAttachment('Error Message',(error as Error).message,'text/plain');
            const screenshot = await browser.takeScreenshot();
            addAttachment('Screenshot on Failure ',Buffer.from(screenshot,'base64'),'image/png');
            throw error;
        }
    }

    /**
     * overwrite specific options to adapt it to page object
     */
    public async open () {
        // return super.open('login');
        // return await driver.launchApp();
        addStep('Launch App');
        return await driver.activateApp('com.aspect.wfxmobile');
    }
}

export default new LoginPage();
