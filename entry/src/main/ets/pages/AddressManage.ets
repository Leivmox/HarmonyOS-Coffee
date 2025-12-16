import { router, promptAction } from '@kit.ArkUI';
import { findAddress } from '../api/api';
import { BusinessError } from '@kit.BasicServicesKit';
import { getStorage } from '../utils/storage'; // 1. 记得导入读取工具

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
  @StorageProp('token') token: string = '';
  @State addressList: AddressItem[] = [];
  @State isLoading: boolean = false;

  // 页面显示时触发
  onPageShow() {
    this.getAddressList();
  }

  // 首次加载触发
  aboutToAppear() {
    this.getAddressList();
  }


  // // --- 新增：专门负责找 Token 的方法 ---
  // checkAndLoadToken() {
  //   // 1. 先看内存(AppStorage)里有没有
  //   if (this.token) {
  //     console.info('内存中有Token，直接使用');
  //     this.getAddressList();
  //   } else {
  //     // 2. 内存里没有，去硬盘(Storage)里找找看
  //     console.info('内存中无Token，尝试从硬盘读取...');
  //     let context = getContext(this);
  //     // 注意：这里的 key "user_token" 必须和你登录页面存的时候一模一样
  //     let diskToken = getStorage("user_token", context);
  //
  //     if (diskToken) {
  //       // 3. 找到了！把它恢复到内存里，这样 @StorageProp 就会自动更新
  //       AppStorage.setOrCreate('token', diskToken.toString());
  //       console.info('Token已从硬盘恢复:', diskToken);
  //
  //       // 恢复后，马上发起网络请求
  //       // (由于 @StorageProp 更新是异步的，这里最好延迟一点点再请求，或者直接用 diskToken 请求)
  //       setTimeout(() => {
  //         this.getAddressList();
  //       }, 100);
  //     } else {
  //       console.warn('硬盘里也没有Token，确实未登录');
  //       // 这里可以做跳转登录页的操作
  //     }
  //   }
  // }

  async getAddressList() {
    if (!this.token) {
      // 可以在这里跳转去登录页，这里暂只打印
      console.warn('Token为空');
      return;
    }

    this.isLoading = true;

    try {
      let res = await findAddress(this.token);

      let resData: Record<string, Object>;
      if (typeof res.result === 'string') {
        resData = JSON.parse(res.result) as Record<string, Object>;
      } else {
        resData = res.result as Record<string, Object>;
      }

      console.info('【调试】服务器状态码:', resData.code);

      // ============================================================
      // 【关键修复】兼容 code: 20000
      // ============================================================
      if (resData.code == 200 || resData.code == '200' || resData.code == 20000) {

        let originList: Array<Record<string, Object>> = [];

        // 提取 result 数组
        if (Array.isArray(resData.result)) {
          originList = resData.result as Array<Record<string, Object>>;
        } else if (Array.isArray(resData.data)) {
          originList = resData.data as Array<Record<string, Object>>;
        }

        console.info('【调试】成功获取地址列表，数量:', originList.length);

        // 映射数据
        this.addressList = originList.map((item: Record<string, Object>) => {
          return {
            id: item.aid as string, // 使用 aid 作为唯一标识
            name: item.name as string,
            phone: item.tel as string,
            // 拼接完整地址
            address: `${item.province || ''}${item.city || ''}${item.county || ''} ${item.addressDetail || ''}`,
            // 处理 isDefault (0 或 1)
            isDefault: item.isDefault === 1 || item.isDefault === true
          } as AddressItem;
        });

      } else {
        console.warn('业务状态码错误:', resData.code);
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
              // 强制转为字符串，防止如果是数字类型导致的问题
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
