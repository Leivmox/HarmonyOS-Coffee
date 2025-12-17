import { router, promptAction } from '@kit.ArkUI';
import { findAddress } from '../api/api';
import { BusinessError } from '@kit.BasicServicesKit';
import { getStorage } from '../utils/storage'; // 1. 导入读取工具

interface AddressItem {
  id: number | string;
  name: string;
  phone: string;
  address: string;
  isDefault: boolean;
}

@Entry
@Component
struct AddressManage {
  // @StorageProp 会监听 AppStorage 中的 'token' 变化
  // 刚重启时，AppStorage为空，所以这里初始值是 ''
  @StorageProp('token') token: string = '';
  @State addressList: AddressItem[] = [];
  @State isLoading: boolean = false;

  // 【核心修改】页面即将出现时，执行“复活”Token的逻辑
  async aboutToAppear() {
    // 1. 如果内存里已经有token（比如是从登录页刚跳过来的），直接请求数据
    if (this.token) {
      console.info('【Token状态】内存中存在，直接请求');
      this.getAddressList();
    } else {
      // 2. 如果内存里没有（比如刚重启APP），尝试去硬盘捞一下
      console.info('【Token状态】内存为空，尝试读取硬盘...');
      let context = getContext(this);

      // 注意：这里需要 await，因为读取硬盘通常是异步的
      // 这里的 key "user_token" 必须和你 LoginPage 里存的一模一样
      let diskToken = await getStorage("user_token", context);

      if (diskToken) {
        console.info('【Token状态】硬盘中找到了！复活Token');

        // 3. 将硬盘读出来的 Token 塞回 AppStorage (内存)
        // 这一步之后，this.token 会自动更新，其他页面也能用
        AppStorage.setOrCreate('token', diskToken as string);

        // 4. 拿到 Token 后，手动调用请求 (传入刚读到的 token，防止 this.token 更新延迟)
        this.getAddressList(diskToken as string);
      } else {
        console.warn('【Token状态】硬盘里也没有，确实未登录');
        promptAction.showToast({ message: '请先登录' });

        // 可选：强制跳转回登录页
        // setTimeout(() => {
        //   router.replaceUrl({ url: 'pages/LoginPage' });
        // }, 1000);
      }
    }
  }

  // 页面显示时触发 (比如从编辑页回来)
  onPageShow() {
    // 如果已经有数据，且 token 存在，可以在这里刷新
    if (this.token) {
      this.getAddressList();
    }
  }

  // 【修改】接收一个可选参数 useToken
  // 因为 @StorageProp 更新有微小的延迟，如果在 aboutToAppear 里刚 set 完马上用 this.token 可能会是空的
  // 所以允许直接传一个 token 进来用
  async getAddressList(useToken?: string) {
    // 优先使用传入的 token，如果没有则使用 this.token
    let finalToken = useToken || this.token;

    if (!finalToken) {
      console.warn('Token为空，无法请求');
      return;
    }

    this.isLoading = true;

    try {
      let res = await findAddress(finalToken);

      let resData: Record<string, Object>;
      if (typeof res.result === 'string') {
        resData = JSON.parse(res.result) as Record<string, Object>;
      } else {
        resData = res.result as Record<string, Object>;
      }

      console.info('【调试】服务器状态码:', resData.code);

      if (resData.code == 200 || resData.code == '200' || resData.code == 20000) {

        let originList: Array<Record<string, Object>> = [];

        if (Array.isArray(resData.result)) {
          originList = resData.result as Array<Record<string, Object>>;
        } else if (Array.isArray(resData.data)) {
          originList = resData.data as Array<Record<string, Object>>;
        }

        this.addressList = originList.map((item: Record<string, Object>) => {
          return {
            id: item.aid as string,
            name: item.name as string,
            phone: item.tel as string,
            address: `${item.province || ''}${item.city || ''}${item.county || ''} ${item.addressDetail || ''}`,
            isDefault: item.isDefault === 1 || item.isDefault === true
          } as AddressItem;
        });

      } else {
        // 如果 Token 过期 (code 401 等)，这里应该处理退出登录逻辑
        promptAction.showToast({ message: resData.msg as string || '获取失败' });
      }

    } catch (err) {
      let error = err as BusinessError;
      console.error('【网络异常】:', JSON.stringify(error));
      promptAction.showToast({ message: '网络请求错误' });
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  AddressCard(item: AddressItem) {
    Row() {
      Column({ space: 8 }) {
        Row({ space: 10 }) {
          Text(item.name).fontSize(16).fontColor('#333').fontWeight(FontWeight.Bold)
          Text(item.phone).fontSize(14).fontColor('#666')
          if (item.isDefault) {
            Text("默认")
              .fontSize(10).fontColor(Color.White).backgroundColor('#0C34BA')
              .padding({ left: 4, right: 4, top: 2, bottom: 2 }).borderRadius(4)
          }
        }.width('100%').alignItems(VerticalAlign.Center)

        Text(item.address)
          .fontSize(14).fontColor('#333').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)

      Image($r('app.media.Edit'))
        .width(25).height(25).objectFit(ImageFit.Contain).fillColor('#999').margin({ left: 16 }).padding(4)
        .onClick(() => {
          router.pushUrl({
            url: "pages/AddressEdit",
            params: {
              aid: item.id + ''
            }
          })
        })
    }
    .width('100%').padding(15).backgroundColor(Color.White).borderRadius(8).margin({ bottom: 10 })
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Row() { Text("< 返回").fontColor('#0C34BA').fontSize(16) }
        .height('100%').onClick(() => router.back()).padding({ left: 15, right: 15 })
        Text("地址管理").fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width("100%").height(56).backgroundColor(Color.White)

      // 列表区域
      if (this.isLoading && this.addressList.length === 0) {
        Column() { Text('加载中...').fontColor('#999').margin({top: 50}) }.width('100%').layoutWeight(1)
      } else if (this.addressList.length === 0) {
        Column() { Text('暂无收货地址').fontColor('#999').fontSize(16).margin({top: 100}) }.width('100%').layoutWeight(1)
      } else {
        List() {
          ForEach(this.addressList, (item: AddressItem) => {
            ListItem() { this.AddressCard(item) }
          })
        }
        .width('100%').layoutWeight(1).padding({ left: 15, right: 15, top: 15 })
      }

      // 底部按钮
      Column() {
        Button("新增地址")
          .width('100%').height(50).backgroundColor('#0C34BA').borderRadius(25)
          .onClick(() => { router.pushUrl({ url: "pages/AddressAdd" }) })
      }.width('100%').padding(20).backgroundColor('#F5F5F5')
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
