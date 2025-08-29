import { addStep, addAttachment } from '@wdio/allure-reporter';
import { TIMEOUT } from 'dns';
import 'dotenv/config';

type Inputs = {
  accountTxtBox: ChainablePromiseElement;
  email:() =>  ChainablePromiseElement;
  password: () => ChainablePromiseElement;
  value1: () => ChainablePromiseElement;
};
type Buttons = {
  Login: () => ChainablePromiseElement;
  Setting: () => ChainablePromiseElement;
  Apply: () => ChainablePromiseElement;
  Continue: () => ChainablePromiseElement;
  AccLogin: () => ChainablePromiseElement;
  SwordFish: () => ChainablePromiseElement;
  Blr: () => ChainablePromiseElement;
  noOptions: () => ChainablePromiseElement;
  popUp: () => ChainablePromiseElement;
};
type DropDown = {
  alvariaTenant: () => ChainablePromiseElement;
};

export class LoginPage {

  readonly inputs: Inputs;
  readonly buttons: Buttons;
  readonly dropDown: DropDown;

  constructor() {
    this.inputs = {
      accountTxtBox: () => $('//android.widget.EditText'),
      email: ()=> $('//android.widget.EditText[@resource-id="email-form-item"]'),
      password: () => $('//android.widget.EditText[@resource-id="password-form-item"]'),
      value1 : () => $('android=new UiSelector().text("Login")')
    },
      this.buttons = {
        Login: () => $('//android.widget.Button[@content-desc="Login"]'),
        Setting: () => $('//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup/android.widget.Button[1]'),
        Apply: () => $('//android.widget.Button[@content-desc="Apply"]'),
        Continue: () => $('//android.widget.Button[@text="Continue"]'),
        AccLogin: () => $('//android.widget.Button[@text="Login"]'),
        SwordFish: () => $('android=new UiSelector().text("Swordfish")'),
        Blr: () => $('android=new UiSelector().description("BLR")'),
        noOptions:() => $('android=new UiSelector().text("No options")'),
        popUp : () => $('android= new UiSelector().text("Show popup")')
      },
      this.dropDown = {
        alvariaTenant: () => $('//android.view.View[@resource-id="radix-vue-combobox-option-nsiNM9WAguS_2"]'),
      };
  }
  public async login(username: string, password: string) {
    try {
      addStep('Start login process');
      await this.buttons.Setting().click();
      console.log("Clicked on setting button");
      await this.buttons.Blr().click();
      console.log("Clicked on Blr button");
      await this.buttons.Apply().click();
      console.log("Clicked on Apply button");
      await this.buttons.Login().click();
      console.log("Clicked on Login button");
      await browser.pause(10000);
      try {
            // Capture screenshot of current screen
            await driver.saveScreenshot('before_account_set.png');
            console.log('Screenshot captured before setting account value.');

            // Capture page source (XML dump of UI hierarchy for inspection)
            const pageSource = await driver.getPageSource();
            console.log('Page Source before setValue: ', pageSource);
            // Save to file for artifact upload
            const fs = require('fs');
            fs.writeFileSync('page_source_before_set.txt', pageSource);

            // Capture available contexts (detects if WebView/browser opened during sign-in)
            const contexts = await driver.getContexts();
            console.log('Available Contexts: ', contexts);
            fs.writeFileSync('contexts_before_set.txt', JSON.stringify(contexts, null, 2));

            // Capture device logs (ADB logcat snippet for errors)
            const logs = await driver.getLogs('logcat');  // Requires 'appium:chromedriverArgs': ['--enable-logging'] in caps for Chrome logs
            fs.writeFileSync('device_logs_before_set.txt', logs.join('\n'));
          } 
        catch (err) {
            console.error('Diagnostic capture failed: ', err);
          }
      const screenshota = await browser.takeScreenshot();
      await this.inputs.accountTxtBox().waitForDisplayed({timeout: 30000 });
      await this.inputs.accountTxtBox().click();
      console.log("Clicked on Login button in the new screen");
      await this.inputs.accountTxtBox().setValue(process.env.Account_Val!);
      console.log("Entered the account value");
      const isNoOptionsVisible = await this.buttons.noOptions().isDisplayed();
      if (isNoOptionsVisible) {
          addStep('No options button visible, clicking popup');
          await this.buttons.popUp().click();
      } 
      else{
        addStep('Selecting Alvaria tenant from dropdown');
        await this.dropDown.alvariaTenant().click();
      }
      await this.buttons.Continue().waitForDisplayed({ timeout: 15000 });
      await this.buttons.Continue().click();
      await this.inputs.email().setValue(username);
      await this.inputs.password().setValue(password);
      await this.buttons.AccLogin().click();
      addStep('Login process complete');
    } catch (error) {
      addStep('Login failed', { status: 'failed' });
      addAttachment('Error Message', (error as Error).message, 'text/plain');
      const screenshot = await browser.takeScreenshot();
      addAttachment('Screenshot on failure', Buffer.from(screenshot, 'base64'), 'image/png');
      throw error;
    }
  }

  public async open() {
    addStep('Launch App');
    return await driver.activateApp('com.aspect.wfxmobile');
  }
}



// import { $ } from '@wdio/globals'
// import {addStep,addAttachment} from '@wdio/allure-reporter';


// const dotenv  = require('dotenv');


// dotenv.config();

// /**
//  * sub page containing specific selectors and methods for a specific page
//  */
// class LoginPage {

  
//     /**
//      * define selectors using getter methods
//      */
//     // public get inputUsername () {
//     //     return $('#username');
//     // }

//     // public get inputPassword () {
//     //     return $('#password');
//     // }
      
//     public get btnLogin () {
//         return $('//android.widget.Button[@content-desc="Login"]');
//     }

//     public get btnSetting () {
//         return $('//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup/android.widget.Button[1]');
//     }

//     public get btnApply () {
//         return $('//android.widget.Button[@content-desc="Apply"]');
//     }

//     public get accountTxtBox () {
//         return $('//android.widget.EditText');
//     }

//     public get btnContinue () {
//         return $('//android.widget.Button[@text="Continue"]');
//     }

//     public get emailText () {
//         return $('//android.widget.EditText[@resource-id="email-form-item"]');
//     }

//     public get passwordText () {
//         return $('//android.widget.EditText[@resource-id="password-form-item"]');
//     }

//     public get btnAccLogin () {
//         return $('//android.widget.Button[@text="Login"]');
//     }

//     /**
//      * a method to encapsule automation code to interact with the page
//      * e.g. to login using username and password
//      */
//     // public async login () {
//     //     try{
//     //     addStep('Application Running Start');
//     //     // await this.inputUsername.setValue(username);
//     //     // await this.inputPassword.setValue(password);
//     //     await this.btnSetting.click();
//     //     addStep('Successfully clicked Login Button');
        
//     //     // const googleAccount = await $('android=new UiSelector().textContains("nithin.murugesan@alvaria.com")');
//     //     // await googleAccount.waitForDisplayed({timeout:10000});
//     //     // await googleAccount.click();
//     //     // await driver.switchContext('com.aspect.wfxmobile');
//     //     // const accountOption = await $('android=new UiSelector().textContains("Continue as")');
//     //     // await accountOption.waitForExist({timeout:5000});
//     //     // await accountOption.click();

//     //     // const condirmgoogleSignin = await $('android=new UiSelector().textContains("Yes")');
//     //     // await condirmgoogleSignin.waitForExist({timeout:5000});
//     //     // await condirmgoogleSignin.click();
//     //     // await driver.pause(10000);
//     //     const account_val = process.env.Account_Val;
//     //     const email = process.env.Email;
//     //        const password = process.env.Password;
//     //      const condirmgoogleSignin = await $('android=new UiSelector().text("Swordfish")');
//     //     await condirmgoogleSignin.waitForExist({timeout:5000});
//     //     await condirmgoogleSignin.click();
//     //      addStep('Successfully logged in google sign in');
//     //     await this.btnApply.click();
//     //      addStep('Successfully Clicked on Apply button');
//     //     await this.btnLogin.click();  
//     //     addStep('Successfully Clicked on Login button');
//     //      await driver.pause(5000);
//     //     await this.accountTxtBox.setValue(account_val!);
//     //     await this.btnContinue.click(); 
//     //     addStep('Successfully Clicked on Continue button');
//     //     await this.emailText.setValue(email!); 
//     //     await this.passwordText.setValue(password!);  
//     //     addStep('Successfully Enter email and password ashish.prasad@aspect.com and Sadsheep66$$');
//     //     await this.btnAccLogin.click();  
//     //     addStep('Successfully Clicked on Account  Login button');
//     //     await driver.pause(10000);
//     //     }
//     //     catch(error){
//     //         addStep('Login failed',{status:'falied'});
//     //         addAttachment('Error Message',(error as Error).message,'text/plain');
//     //         const screenshot = await browser.takeScreenshot();
//     //         addAttachment('Screenshot on Failure ',Buffer.from(screenshot,'base64'),'image/png');
//     //         throw error;
//     //     }
//     // }
//     public async login(username: string, password: string) {
//     try {
//       addStep('Start login process');
//       await this.buttons.Setting().click();
//       await this.buttons.Blr().click();
//       await this.buttons.Apply().click();
//       await this.buttons.Login().click();
//       await this.inputs.accountTxtBox().waitForDisplayed({ timeout: 30000 });
//       await this.inputs.accountTxtBox().setValue(process.env.Account_Val!);
//       const isNoOptionsVisible = await this.buttons.noOptions().isDisplayed();
//       if (isNoOptionsVisible) {
//           addStep('No options button visible, clicking popup');
//           await this.buttons.popUp().click();
//       } 
//       else{
//         addStep('Selecting Alvaria tenant from dropdown');
//         await this.dropDown.alvariaTenant().click();
//       }
//       await this.buttons.Continue().waitForDisplayed({ timeout: 15000 });
//       await this.buttons.Continue().click();
//       await this.inputs.email().setValue(username);
//       await this.inputs.password().setValue(password);
//       await this.buttons.AccLogin().click();
//       addStep('Login process complete');
//     } catch (error) {
//       addStep('Login failed', { status: 'failed' });
//       addAttachment('Error Message', (error as Error).message, 'text/plain');
//       const screenshot = await browser.takeScreenshot();
//       addAttachment('Screenshot on failure', Buffer.from(screenshot, 'base64'), 'image/png');
//       throw error;
//     }
//   }
//     /**
//      * overwrite specific options to adapt it to page object
//      */
//     public async open () {
//         // return super.open('login');
//         // return await driver.launchApp();
//         addStep('Launch App');
//         console.log("Launching the app");
//         console.log("launched app");
//         return await driver.activateApp('com.aspect.wfxmobile');
//     }
// }

// export default new LoginPage();
