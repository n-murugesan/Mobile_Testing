import {LoginPage} from '../pageobjects/login.page';


// describe('My test', () => {
//     beforeEach(() => {
//         const port = browser.options.port;
//         console.log(port);
//     })
//     })


describe('My Login application', () => {
    const loginPage = new LoginPage();
    it('should login with valid credentials', async () => {
        await loginPage.open();
        console.log("Opened the page");
        await loginPage.login(process.env.EMAIL!, process.env.PASSWORD!);
    })
})

