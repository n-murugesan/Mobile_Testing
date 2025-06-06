import LoginPage from '../pageobjects/login.page'


// describe('My test', () => {
//     beforeEach(() => {
//         const port = browser.options.port;
//         console.log(port);
//     })
//     })


describe('My Login application', () => {
    it('should login with valid credentials', async () => {
        await LoginPage.open()
        await LoginPage.login()
    })
})

